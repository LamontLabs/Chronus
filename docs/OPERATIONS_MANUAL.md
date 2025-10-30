# OPERATIONS MANUAL

## Daily
1. git pull --rebase
2. make verify
3. pnpm start  (smoke test: load → build → prestige → save)
4. Inspect /provenance/logs/ for chain integrity
5. Commit and tag: [buildID] <summary> then push

## Weekly
- make binder  → archive to /provenance/binders/
- Review /assets/events/rotation.json
- Run QA: /qa/test_runner.py  → store report in /qa/reports/

## Monthly
- Rotate signing keys; update /provenance/keys/
- License scan: /tools/license_scan.sh  → store in /provenance/legal/
- Purge telemetry older than 30 days: /tools/purge_telemetry.sh

## Incident Response
1. Freeze deploys
2. Restore last verified save
3. Rebuild with fresh seed
4. File RCA at /provenance/incidents/YYYY-MM-DD.md

## Change Control
- PRs only; CI must pass determinism, QA, license scan
- Maintainers tag releases
