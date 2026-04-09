"""
Reusable BL4 injector service.

This module keeps the game-attachment and live backpack injection logic in one
place so multiple frontends can reuse it: the existing WebSocket bridge, a
local HTTP helper, or future desktop packaging.
"""

from __future__ import annotations

import ctypes
import ctypes.wintypes as wt
import struct
import time
from pathlib import Path

from bl4_scanner import (
    alloc_mem,
    find_process,
    get_module_info,
    read_mem,
    read_ptr,
    read_u32,
    write_mem,
)
from find_gengine_direct import find_gengine_scan_sections


user32 = ctypes.WinDLL("user32", use_last_error=True)
WM_KEYDOWN = 0x0100
WM_KEYUP = 0x0101
VK_R = 0x52
MAPVK_VK_TO_VSC = 0
WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wt.HWND, wt.LPARAM)

ITEM_SIZE = 0x150
STATE_BACKPACK_DATA = 0x880
STATE_BACKPACK_COUNT = 0x888
STATE_BACKPACK_MAX = 0x88C
STATE_BACKPACK_MAX_SIZE = 0x924
ITEM_SERIAL_PTR = 0xB8
ITEM_TYPE_PTR = 0x18
ITEM_REPLICATION_ID = 0x00
ITEM_REPLICATION_KEY = 0x04
ITEM_MOST_RECENT = 0x08
ITEM_INSTANCE_ID = 0x10
ITEM_QUANTITY = 0xF8
ITEM_FLAGS = 0xFC
ITEM_HANDLE = 0x108
ITEM_EQUIP_SLOT = 0x10D
ITEM_MAX_QUANTITY = 0x138
GENGINE_OVERRIDE_FILE = Path(__file__).with_name("gengine_override.txt")


class GameState:
    def __init__(self) -> None:
        self.pid: int | None = None
        self.handle = None
        self.gengine: int | None = None
        self.base: int | None = None
        self.size: int | None = None
        self.connected = False

    def attach(self) -> dict:
        """Attach to BL4 and auto-find GEngine."""
        self.pid, self.handle = find_process()
        if not self.handle:
            self.connected = False
            return {"ok": False, "error": "Borderlands 4 not found. Is the game running?"}

        self.base, self.size = get_module_info(self.pid)
        if not self.base:
            self.connected = False
            return {"ok": False, "error": "Could not get module info"}

        self.connected = True
        print(f"[+] Attached to BL4 (PID: {self.pid})")
        print("[*] Finding GEngine...")
        self.gengine = find_gengine_scan_sections(self.handle, self.base, self.size)
        if self.gengine:
            print(f"[+] GEngine: {hex(self.gengine)}")
        else:
            print("[!] GEngine not found automatically. Trying gengine_override.txt...")
            override_result = self._try_gengine_override()
            if override_result:
                print(f"[+] Using GEngine override: {hex(self.gengine)}")
            else:
                print("[!] GEngine not found. Are you in-game (not main menu)?")

        result = {"ok": True, "pid": self.pid}
        if self.gengine:
            result["gengine"] = hex(self.gengine)
        return result

    def _try_gengine_override(self) -> bool:
        if not self.handle:
            return False
        if not GENGINE_OVERRIDE_FILE.exists():
            return False

        raw = GENGINE_OVERRIDE_FILE.read_text(encoding="utf-8").strip()
        if not raw:
            return False
        raw = raw.splitlines()[0].split("#", 1)[0].split(";", 1)[0].strip()
        if not raw:
            return False

        try:
            value = int(raw, 0)
        except ValueError:
            print(f"[!] Invalid GEngine override in {GENGINE_OVERRIDE_FILE.name}: {raw!r}")
            return False

        previous = self.gengine
        self.gengine = value
        info = self._get_backpack_info()
        if info:
            return True

        self.gengine = previous
        print(f"[!] GEngine override {hex(value)} did not validate against the live backpack chain.")
        return False

    def _get_state(self) -> int | None:
        """Walk the current local-player chain to PlayerState."""
        if not self.handle or not self.gengine:
            return None
        game_instance = read_ptr(self.handle, self.gengine + 0x1358)
        if not game_instance:
            return None
        local_players = read_ptr(self.handle, game_instance + 0x38)
        if not local_players:
            return None
        player0 = read_ptr(self.handle, local_players)
        if not player0:
            return None
        controller = read_ptr(self.handle, player0 + 0x30)
        if not controller:
            return None
        return read_ptr(self.handle, controller + 0x398)

    def _get_backpack_info(self) -> dict | None:
        state = self._get_state()
        if not state:
            return None

        bp_data = read_ptr(self.handle, state + STATE_BACKPACK_DATA)
        bp_count = read_u32(self.handle, state + STATE_BACKPACK_COUNT)
        bp_max = read_u32(self.handle, state + STATE_BACKPACK_MAX)
        bp_max_size = read_u32(self.handle, state + STATE_BACKPACK_MAX_SIZE)
        if not bp_data or bp_count is None or bp_max is None:
            return None

        return {
            "state": state,
            "data": bp_data,
            "count": bp_count,
            "max": bp_max,
            "max_size": bp_max_size,
        }

    def _find_empty_template(self, bp_data: int, bp_count: int) -> bytes | None:
        for index in range(bp_count):
            item_addr = bp_data + (index * ITEM_SIZE)
            if self._is_empty_slot(item_addr):
                template = read_mem(self.handle, item_addr, ITEM_SIZE)
                if template:
                    return template
        return None

    def _ensure_capacity(self, info: dict, needed: int) -> tuple[bool, dict | None, str | None]:
        bp_count = info["count"]
        bp_max = info["max"]
        max_size = info["max_size"]
        if bp_count + needed <= bp_max:
            return True, info, None

        if max_size and bp_count >= max_size:
            return False, None, f"Backpack full ({bp_count}/{max_size})"

        new_max = max(bp_max + max(needed, 16), bp_count + needed)
        if max_size:
            new_max = min(new_max, max_size)
        if new_max <= bp_count:
            return False, None, "Could not grow backpack array safely"

        new_array = alloc_mem(self.handle, new_max * ITEM_SIZE)
        if not new_array:
            return False, None, "Could not allocate memory"

        old_data = read_mem(self.handle, info["data"], bp_count * ITEM_SIZE)
        if bp_count > 0 and old_data:
            write_mem(self.handle, new_array, old_data)

        write_mem(self.handle, info["state"] + STATE_BACKPACK_DATA, struct.pack("<Q", new_array))
        write_mem(self.handle, info["state"] + STATE_BACKPACK_MAX, struct.pack("<I", new_max))

        info = dict(info)
        info["data"] = new_array
        info["max"] = new_max
        return True, info, None

    def _write_slot(self, new_addr: int, new_id: int, serial: str, template: bytes | None) -> bool:
        if template:
            write_mem(self.handle, new_addr, template)
        else:
            write_mem(self.handle, new_addr, b"\x00" * ITEM_SIZE)
            write_mem(self.handle, new_addr + ITEM_REPLICATION_ID, struct.pack("<I", 0xFFFFFFFF))
            write_mem(self.handle, new_addr + ITEM_REPLICATION_KEY, struct.pack("<I", 0xFFFFFFFF))
            write_mem(self.handle, new_addr + ITEM_MOST_RECENT, struct.pack("<I", 0xFFFFFFFF))
            write_mem(self.handle, new_addr + 0x80, struct.pack("<Q", 0x8000000000))
            write_mem(self.handle, new_addr + 0x88, struct.pack("<I", 0xFFFFFFFF))
            write_mem(self.handle, new_addr + 0xD0, struct.pack("<I", 0x0F))
            write_mem(self.handle, new_addr + 0xD8, struct.pack("<I", 1))

        write_mem(self.handle, new_addr + ITEM_REPLICATION_ID, struct.pack("<I", new_id))
        write_mem(self.handle, new_addr + ITEM_REPLICATION_KEY, struct.pack("<I", 0))
        write_mem(self.handle, new_addr + ITEM_MOST_RECENT, struct.pack("<I", 0xFFFFFFFF))
        write_mem(self.handle, new_addr + ITEM_INSTANCE_ID, struct.pack("<I", new_id))
        write_mem(self.handle, new_addr + ITEM_HANDLE, struct.pack("<I", new_id))
        write_mem(self.handle, new_addr + ITEM_EQUIP_SLOT, bytes([0xFF]))
        write_mem(self.handle, new_addr + ITEM_QUANTITY, struct.pack("<I", 1))
        write_mem(self.handle, new_addr + ITEM_FLAGS, struct.pack("<I", 1))
        write_mem(self.handle, new_addr + ITEM_MAX_QUANTITY, struct.pack("<I", 1))

        str_buf = alloc_mem(self.handle, len(serial) + 64)
        if not str_buf:
            return False
        write_mem(self.handle, str_buf, serial.encode("utf-8") + b"\x00")
        write_mem(self.handle, new_addr + ITEM_SERIAL_PTR, struct.pack("<Q", str_buf))
        return True

    def read_backpack(self, limit: int = 200) -> dict:
        info = self._get_backpack_info()
        if not info:
            return {"ok": False, "error": "Could not find player state. Are you in-game?"}

        items = []
        for index in range(min(info["count"], limit)):
            item_addr = info["data"] + (index * ITEM_SIZE)
            str_ptr = read_ptr(self.handle, item_addr + ITEM_SERIAL_PTR)
            serial = ""
            if str_ptr:
                raw = read_mem(self.handle, str_ptr, 300)
                if raw:
                    null = raw.find(b"\x00")
                    if null > 0:
                        serial = raw[:null].decode("utf-8", errors="replace")
            equip = read_mem(self.handle, item_addr + ITEM_EQUIP_SLOT, 1)
            items.append(
                {
                    "slot": index,
                    "serial": serial,
                    "equipSlot": equip[0] if equip else 255,
                    "quantity": read_u32(self.handle, item_addr + ITEM_QUANTITY) or 1,
                }
            )

        return {
            "ok": True,
            "count": info["count"],
            "max": info["max"],
            "max_size": info["max_size"],
            "items": items,
        }

    def inject_item(self, serial: str) -> dict:
        if not serial.startswith("@U"):
            return {"ok": False, "error": "Serial must start with @U"}

        info = self._get_backpack_info()
        if not info:
            return {"ok": False, "error": "Could not find player state"}

        ok, info, error = self._ensure_capacity(info, 1)
        if not ok:
            return {"ok": False, "error": error}

        template = self._find_empty_template(info["data"], info["count"])
        slot = info["count"]
        new_addr = info["data"] + (slot * ITEM_SIZE)
        new_id = slot + 200
        if not self._write_slot(new_addr, new_id, serial, template):
            return {"ok": False, "error": "Could not allocate string memory"}

        write_mem(self.handle, info["state"] + STATE_BACKPACK_COUNT, struct.pack("<I", slot + 1))
        return {"ok": True, "message": f"Injected to slot {slot}! Open inventory to see it.", "slot": slot}

    def batch_inject(self, serials: list[str]) -> dict:
        clean_serials = [serial.strip() for serial in serials if isinstance(serial, str) and serial.strip()]
        invalid = [serial for serial in clean_serials if not serial.startswith("@U")]
        if invalid:
            return {"ok": False, "error": "All serials must start with @U"}
        if not clean_serials:
            return {"ok": False, "error": "No serials provided"}

        info = self._get_backpack_info()
        if not info:
            return {"ok": False, "error": "Could not find player state"}

        ok, info, error = self._ensure_capacity(info, len(clean_serials))
        if not ok:
            return {"ok": False, "error": error}

        template = self._find_empty_template(info["data"], info["count"])
        injected = 0
        count = info["count"]
        for index, serial in enumerate(clean_serials):
            slot = count
            new_addr = info["data"] + (slot * ITEM_SIZE)
            new_id = slot + 500 + index
            if not self._write_slot(new_addr, new_id, serial, template):
                break
            count += 1
            injected += 1

        write_mem(self.handle, info["state"] + STATE_BACKPACK_COUNT, struct.pack("<I", count))
        print(f"[+] Batch injected {injected}/{len(clean_serials)} items")
        return {"ok": True, "injected": injected, "message": f"Injected {injected} items!"}

    def _get_game_window(self):
        if not self.pid:
            return None
        result = [None]

        def callback(hwnd, _lparam):
            proc_id = wt.DWORD()
            user32.GetWindowThreadProcessId(hwnd, ctypes.byref(proc_id))
            if proc_id.value == self.pid and user32.IsWindowVisible(hwnd):
                length = user32.GetWindowTextLengthW(hwnd)
                if length > 0:
                    buf = ctypes.create_unicode_buffer(length + 1)
                    user32.GetWindowTextW(hwnd, buf, length + 1)
                    if buf.value:
                        result[0] = hwnd
                        return False
            return True

        user32.EnumWindows(WNDENUMPROC(callback), 0)
        return result[0]

    def drop_items(self, count: int, hold_seconds: float = 1.5, delay: float = 0.5) -> dict:
        hwnd = self._get_game_window()
        if not hwnd:
            return {"ok": False, "error": "Game window not found"}

        scan_code = user32.MapVirtualKeyW(VK_R, MAPVK_VK_TO_VSC)
        lp_down = (scan_code << 16) | 1
        lp_up = (scan_code << 16) | 1 | (1 << 30) | (1 << 31)

        dropped = 0
        for _ in range(count):
            try:
                user32.SendMessageW(hwnd, WM_KEYDOWN, VK_R, lp_down)
                time.sleep(hold_seconds)
                user32.SendMessageW(hwnd, WM_KEYUP, VK_R, lp_up)
                time.sleep(delay)
                dropped += 1
                print(f"  [{dropped}/{count}] Dropped")
            except Exception as exc:
                return {"ok": True, "dropped": dropped, "error": f"Stopped at {dropped}: {exc}"}

        return {"ok": True, "dropped": dropped, "message": f"Dropped {dropped} items!"}

    def status(self) -> dict:
        info = self._get_backpack_info()
        return {
            "ok": True,
            "connected": self.connected,
            "pid": self.pid,
            "gengine": hex(self.gengine) if self.gengine else None,
            "backpack_ready": info is not None,
            "backpack_count": info["count"] if info else None,
            "backpack_max": info["max"] if info else None,
            "backpack_max_size": info["max_size"] if info else None,
        }
