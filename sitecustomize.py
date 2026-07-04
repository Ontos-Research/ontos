# Auto-imported by Python at interpreter startup (via site.py) when on sys.path.
#
# Escape hatch for TLS-intercepting corporate proxies whose root/leaf CA is
# malformed in a way modern OpenSSL (3.x, in the container) rejects but the host
# tolerates — e.g. a WSA-generated cert missing the RFC 5280 Authority Key
# Identifier. No CA bundle can fix a structurally-invalid cert, so when
# ONTOS_TLS_SKIP_VERIFY is set we relax the interpreter's DEFAULT TLS context.
#
# Our control plane's LLM egress uses stdlib urllib (not httpx), so patching the
# ssl module's default-context factories reaches it — the compiled app code calls
# these at request time and picks up the patched versions. No-op unless the env
# var is set, so this is safe to leave mounted by default.
import os

if os.environ.get("ONTOS_TLS_SKIP_VERIFY"):
    try:
        import ssl

        _unverified = ssl._create_unverified_context
        ssl._create_default_https_context = _unverified
        ssl.create_default_context = _unverified
    except Exception:
        pass
