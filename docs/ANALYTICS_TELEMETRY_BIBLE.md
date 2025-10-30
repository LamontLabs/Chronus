# ANALYTICS & TELEMETRY BIBLE

## Purpose
Telemetry used solely to refine pacing and balance.  
All data anonymous and optional.

## Metrics
session_length  
return_interval  
resource_balance  
automation_usage  
menu_navigation  
retention_curve

## Retention Logic
if D7 < 20 % → boost early rewards  
if D30 > 12 % → increase challenge slope 5 %  
Adjustments logged in patch notes.

## Storage
`/assets/telemetry/metrics.json`  
Auto-deletes after 30 days.

## Security
Data encrypted AES-256 at rest.  
Opt-in toggle in settings.  
Exports hashed to `/provenance/telemetry/`.

## Transparency
Player can view analytics dashboard locally (no network).
