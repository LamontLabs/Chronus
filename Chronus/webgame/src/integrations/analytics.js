const q = [];
let enabled = true;

export function setEnabled(v){ enabled = !!v; }
export function track(type, payload = {}) {
  if (!enabled) return;
  q.push({ t: Date.now(), type, payload });
  if (q.length >= 20) flush();
}
export async function flush() {
  try {
    const batch = q.splice(0, q.length);
    // Hook your endpoint or Firebase here:
    // await fetch('https://example.invalid/analytics', {method:'POST', body: JSON.stringify(batch)});
    return batch.length;
  } catch { return 0; }
}
// Suggested taxonomy: start_session, prestige, offline_return, achievement, ad_opt_in
