export const clamp = (v, min, max) => Math.max(min, Math.min(max, v));

export const lerp = (a, b, t) => a + (b - a) * t;

export const formatNum = (n) => {
  if (n < 1000) return n.toFixed(2);
  const units = ["", "K", "M", "B", "T", "Qa", "Qi"];
  let idx = 0;
  while (n >= 1000 && idx < units.length - 1) {
    n /= 1000;
    idx++;
  }
  return `${n.toFixed(2)}${units[idx]}`;
};
