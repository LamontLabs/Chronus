#!/usr/bin/env python3
import hashlib, json, os, sys, glob, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROV = ROOT / "provenance" / "logs"
PROV.mkdir(parents=True, exist_ok=True)

EXCLUDE = {
    "node_modules",
    "dist",
    "build",
    ".git",
    ".pnpm-store",
    "__pycache__",
    ".expo",
    ".gradle",
    ".idea",
}

def should_skip(path: Path) -> bool:
    parts = set(path.parts)
    return any(p in EXCLUDE for p in parts)

def file_hash(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    artifacts = []
    for p in ROOT.rglob("*"):
        if p.is_file() and not should_skip(p):
            artifacts.append({
                "path": str(p.relative_to(ROOT)),
                "sha256": file_hash(p)
            })
    snapshot = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "count": len(artifacts),
        "artifacts": artifacts,
    }
    out = PROV / f"hash_snapshot_{int(time.time())}.json"
    with open(out, "w") as f:
        json.dump(snapshot, f, indent=2)
    print(f"[verify] Wrote {out}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
