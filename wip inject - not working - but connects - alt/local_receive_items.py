"""
Local BL4 Receive Items helper.

Runs a local-only HTTP server that exposes a minimal API and serves a browser UI
for pasting @U serials and injecting them into the live game.
"""

from __future__ import annotations

import argparse
import json
import mimetypes
import threading
import webbrowser
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

from bl4_service import GameState


STATIC_DIR = Path(__file__).with_name("static")
DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 27115

game = GameState()


class ReceiveItemsHandler(BaseHTTPRequestHandler):
    server_version = "BL4ReceiveItems/0.1"

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/":
            self._serve_static("receive-items.html")
            return
        if parsed.path == "/receive-items.css":
            self._serve_static("receive-items.css")
            return
        if parsed.path == "/receive-items.js":
            self._serve_static("receive-items.js")
            return
        if parsed.path == "/api/status":
            self._write_json(HTTPStatus.OK, game.status())
            return
        if parsed.path == "/api/backpack":
            self._write_json(HTTPStatus.OK, game.read_backpack())
            return
        self._write_json(HTTPStatus.NOT_FOUND, {"ok": False, "error": "Not found"})

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        payload = self._read_json_body()
        if payload is None:
            return

        if parsed.path == "/api/attach":
            self._write_json(HTTPStatus.OK, game.attach())
            return

        if parsed.path == "/api/inject":
            serial = payload.get("serial", "")
            self._write_json(HTTPStatus.OK, game.inject_item(str(serial)))
            return

        if parsed.path == "/api/batch-inject":
            serials = payload.get("serials", [])
            if not isinstance(serials, list):
                self._write_json(
                    HTTPStatus.BAD_REQUEST,
                    {"ok": False, "error": "serials must be an array"},
                )
                return
            self._write_json(HTTPStatus.OK, game.batch_inject(serials))
            return

        if parsed.path == "/api/drop-all":
            count = payload.get("count", 1)
            try:
                self._write_json(HTTPStatus.OK, game.drop_items(int(count)))
            except (TypeError, ValueError):
                self._write_json(HTTPStatus.BAD_REQUEST, {"ok": False, "error": "count must be an integer"})
            return

        self._write_json(HTTPStatus.NOT_FOUND, {"ok": False, "error": "Not found"})

    def log_message(self, format: str, *args) -> None:
        print(f"[http] {self.address_string()} - {format % args}")

    def _read_json_body(self) -> dict | None:
        length_header = self.headers.get("Content-Length", "0")
        try:
            length = int(length_header)
        except ValueError:
            self._write_json(HTTPStatus.BAD_REQUEST, {"ok": False, "error": "Invalid Content-Length"})
            return None

        raw_body = self.rfile.read(length) if length > 0 else b"{}"
        try:
            return json.loads(raw_body.decode("utf-8") or "{}")
        except json.JSONDecodeError:
            self._write_json(HTTPStatus.BAD_REQUEST, {"ok": False, "error": "Invalid JSON body"})
            return None

    def _serve_static(self, filename: str) -> None:
        file_path = STATIC_DIR / filename
        if not file_path.exists():
            self._write_json(HTTPStatus.NOT_FOUND, {"ok": False, "error": "Static file not found"})
            return

        content_type = mimetypes.guess_type(file_path.name)[0] or "application/octet-stream"
        content = file_path.read_bytes()
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

    def _write_json(self, status: HTTPStatus, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the local BL4 Receive Items helper.")
    parser.add_argument("--host", default=DEFAULT_HOST, help=f"Local bind host (default: {DEFAULT_HOST})")
    parser.add_argument("--port", default=DEFAULT_PORT, type=int, help=f"Local bind port (default: {DEFAULT_PORT})")
    parser.add_argument(
        "--no-browser",
        action="store_true",
        help="Do not automatically open the local Receive Items page in the browser.",
    )
    parser.add_argument(
        "--attach-on-start",
        action="store_true",
        help="Try attaching to BL4 immediately on startup.",
    )
    return parser.parse_args()


def maybe_open_browser(host: str, port: int) -> None:
    url = f"http://{host}:{port}/"
    print(f"[*] Opening browser: {url}")
    threading.Timer(1.0, lambda: webbrowser.open(url)).start()


def main() -> None:
    args = parse_args()

    print("BL4 Receive Items Helper")
    print(f"[*] Serving local UI at http://{args.host}:{args.port}/")
    print("[*] Press Ctrl+C to stop")

    if args.attach_on_start:
        print("[*] Attempting initial attach...")
        result = game.attach()
        if result.get("ok"):
            print("[+] Initial attach succeeded")
        else:
            print(f"[!] Initial attach failed: {result.get('error')}")

    try:
        server = ThreadingHTTPServer((args.host, args.port), ReceiveItemsHandler)
    except PermissionError:
        print(f"[!] Could not bind to http://{args.host}:{args.port}/")
        print("[!] That port is already in use or blocked by another process.")
        print("[!] Try a different port, for example:")
        print(f"    python local_receive_items.py --attach-on-start --port {DEFAULT_PORT}")
        return

    if not args.no_browser:
        maybe_open_browser(args.host, args.port)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[*] Shutting down helper...")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
