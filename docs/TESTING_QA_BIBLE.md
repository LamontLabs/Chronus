# TESTING & QA BIBLE

## Testing Stages
Alpha → Closed Beta → Open Beta → Global Launch.

### Alpha
- Core loop validation (production, automation, prestige).  
- Deterministic save/load checks.  
- Frame budget profiling (<16 ms/frame).

### Closed Beta
- 200 testers across devices.  
- Validate EAS build pipeline.  
- Verify offline persistence (12h cap).

### Open Beta
- Retention, ad opt-in, and monetization telemetry.  
- Crash rate < 1 %.  
- Regression suite auto-run.

### QA Tools
- `/tools/test_runner.py` deterministic simulation.  
- `/tools/compare_saves.py` verifies save integrity.

### Reporting
All bug reports → `/qa/reports/` JSON schema.

### Signoff
Each build tagged only if tests PASS; fail-closed otherwise.

Exports: `/qa/`
