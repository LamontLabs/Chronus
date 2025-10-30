# SECURITY & PRIVACY COMPLIANCE BIBLE

## Principles
1. Transparency — every stored datum visible to user.  
2. Sovereignty — offline data always authoritative.  
3. Verification — cryptographic integrity on each save.

## Data Handling
- AES-256 local encryption key derived from PBKDF2(device ID).  
- Ed25519 signatures for provenance logs.  
- No hidden analytics; telemetry optional and anonymous.

## User Rights
- Data export to JSON/ZIP binder.  
- Data purge button wipes all files irreversibly.  
- GDPR / CCPA compliant disclosures inside Settings → Privacy.

## Provenance Logs
`/provenance/logs/` store hashes per session:
