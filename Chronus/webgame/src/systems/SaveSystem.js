const KEY = "chronus_save";

export default class SaveSystem {
  constructor(state) {
    this.state = state;
    this.interval = null;
  }

  startAutoSave(scene) {
    if (this.interval) clearInterval(this.interval);
    this.interval = setInterval(() => this.save(), 5000);
    scene.events.on("shutdown", () => clearInterval(this.interval));
  }

  save() {
    const payload = this.state.snapshot();
    payload.ts = Date.now();
    localStorage.setItem(KEY, JSON.stringify(payload));
    return payload;
  }

  load() {
    try {
      const raw = localStorage.getItem(KEY);
      if (!raw) return null;
      const obj = JSON.parse(raw);
      if (obj && typeof obj === "object") {
        this.state.load(obj);
        return obj;
      }
    } catch (_) {}
    return null;
  }

  clear() {
    localStorage.removeItem(KEY);
  }
}
