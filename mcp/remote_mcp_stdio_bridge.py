import json
import os
import sys
from typing import Any, Dict, Optional
from urllib import error, request


DEFAULT_REMOTE_MCP_URL = "http://127.0.0.1:8080/api/v1/mcp"


def remote_mcp_url() -> str:
    return os.environ.get("DATADEX_REMOTE_MCP_URL") or DEFAULT_REMOTE_MCP_URL


def remote_mcp_api_key() -> str:
    return os.environ.get("DATADEX_REMOTE_MCP_API_KEY") or os.environ.get("DATADEX_API_KEY") or ""


def send(message: Dict[str, Any]) -> None:
    sys.stdout.write(json.dumps(message, separators=(",", ":")) + "\n")
    sys.stdout.flush()


def error_response(request_id: Any, code: int, message: str) -> Dict[str, Any]:
    return {"jsonrpc": "2.0", "id": request_id, "error": {"code": code, "message": message}}


def call_remote_mcp(message: Dict[str, Any]) -> Dict[str, Any]:
    api_key = remote_mcp_api_key()
    if not api_key:
        return error_response(message.get("id"), -32001, "Missing DATADEX_REMOTE_MCP_API_KEY")

    payload = json.dumps(message).encode("utf-8")
    req = request.Request(
        remote_mcp_url(),
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
        method="POST",
    )
    try:
        with request.urlopen(req, timeout=20) as response:
            return json.loads(response.read().decode("utf-8"))
    except error.HTTPError as exc:
        body = exc.read().decode("utf-8")
        try:
            payload = json.loads(body)
            message_text = payload.get("error", {}).get("message") or body
        except json.JSONDecodeError:
            message_text = body or str(exc)
        return error_response(message.get("id"), -32000, f"Remote MCP HTTP {exc.code}: {message_text}")
    except Exception as exc:
        return error_response(message.get("id"), -32000, f"Remote MCP call failed: {exc}")


def handle_request(message: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    if message.get("id") is None:
        if message.get("method") in {"notifications/initialized", "notifications/cancelled"}:
            return None
        return None
    return call_remote_mcp(message)


def main() -> int:
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            message = json.loads(line)
        except json.JSONDecodeError as exc:
            send(error_response(None, -32700, f"Parse error: {exc.msg}"))
            continue
        response = handle_request(message)
        if response is not None:
            send(response)
    return 0


if __name__ == "__main__":
    sys.exit(main())
