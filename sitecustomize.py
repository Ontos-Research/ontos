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
    # requests / urllib3 (used by the secure-agent's cloud connectors, e.g. the BigQuery client)
    # build their OWN SSLContext via urllib3.util.ssl_.create_urllib3_context — NOT the stdlib
    # factories patched above — so the patch above does not reach them. Relax that factory too, or
    # a TLS-intercepting proxy still fails the handshake for those clients. Opt-in only (this whole
    # block is gated on ONTOS_TLS_SKIP_VERIFY), and fully defensive so a urllib3 version skew can
    # never break interpreter startup.
    try:
        import ssl as _ssl
        import urllib3
        from urllib3.util import ssl_ as _u3

        urllib3.disable_warnings()
        _orig_ctx = _u3.create_urllib3_context

        def _skip_verify_ctx(*args, **kwargs):
            ctx = _orig_ctx(*args, **kwargs)
            ctx.check_hostname = False              # must precede CERT_NONE or Python raises
            ctx.verify_mode = _ssl.CERT_NONE
            return ctx

        _u3.create_urllib3_context = _skip_verify_ctx
    except Exception:
        pass
