"""
BL4 Live Injector WebSocket bridge.

This keeps the existing WebSocket workflow available while delegating the
actual game logic to the reusable service module.
"""

from __future__ import annotations

import asyncio
import json
import sys

from bl4_service import GameState


game = GameState()


async def handle_ws(websocket) -> None:
    print("[+] Web app connected")
    try:
        async for message in websocket:
            req = {}
            try:
                req = json.loads(message)
                action = req.get("action", "")

                if action == "ping":
                    resp = {"ok": True, "bridge": "bl4-live-injector", "version": "2.1.0"}
                elif action == "attach":
                    resp = game.attach()
                elif action == "status":
                    resp = game.status()
                elif action == "read_backpack":
                    resp = game.read_backpack()
                elif action == "inject":
                    serial = req.get("serial", "")
                    resp = game.inject_item(serial)
                    if resp.get("ok"):
                        print(f"[+] Injected item ({len(serial)} chars)")
                elif action == "batch_inject":
                    resp = game.batch_inject(req.get("serials", []))
                elif action == "drop_all":
                    count = req.get("count", 1)
                    print(f"[*] Dropping {count} items...")
                    resp = game.drop_items(count)
                else:
                    resp = {"ok": False, "error": f"Unknown action: {action}"}

                if "_id" in req:
                    resp["_id"] = req["_id"]
                await websocket.send(json.dumps(resp))
            except Exception as exc:
                err = {"ok": False, "error": str(exc)}
                if "_id" in req:
                    err["_id"] = req["_id"]
                await websocket.send(json.dumps(err))
    except Exception:
        pass
    finally:
        print("[-] Web app disconnected")


async def main() -> None:
    try:
        import websockets
    except ImportError:
        print("Installing websockets...")
        import subprocess

        subprocess.check_call([sys.executable, "-m", "pip", "install", "websockets"])
        import websockets

    port = 27015

    print(
        r"""
 ____  _   _  _     _     _           _
| __ )| | | || |   (_)_ __(_) ___  ___| |_ ___  _ __
|  _ \| | | || |   | | '__| |/ _ \/ __| __/ _ \| '__|
| |_) | |_| || |___| | |  | |  __/ (__| || (_) | |
|____/ \___/ |_____|_|_|  |_|\___|\___|\__\___/|_|

  BL4 Live Injector v2.1
"""
    )

    print("[*] Looking for Borderlands 4...")
    result = game.attach()
    if result.get("ok"):
        if game.gengine:
            backpack = game.read_backpack()
            if backpack.get("ok"):
                print(f"[+] Ready! Backpack: {backpack['count']} items")
        print(f"\n[*] WebSocket server starting on ws://localhost:{port}")
        print("[*] Open bl4editor.com and click 'Inject to Game'")
    else:
        print(f"[!] {result.get('error')}")
        print("[*] Will retry when web app connects...")
        print(f"\n[*] WebSocket server starting on ws://localhost:{port}")

    print("[*] Press Ctrl+C to stop\n")

    async with websockets.serve(handle_ws, "localhost", port, origins=None):
        await asyncio.Future()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n[*] Shutting down...")
