export default class State {
  constructor() {
    this.data = {
      energy: 10,
      food: 0,
      wood: 0,
      stone: 0,
      metal: 0,
      knowledge: 0,
      artifacts: 0,
      chronoshards: 0,
      automation: 1,
      legacy: 0,
      prestige: 0,
      era: "fire",
      ts: Date.now()
    };
  }

  read(key, def = 0) {
    return this.data[key] ?? def;
  }

  write(key, val) {
    this.data[key] = val;
    return val;
  }

  add(key, val) {
    this.data[key] = (this.data[key] || 0) + val;
    return this.data[key];
  }

  snapshot() {
    return JSON.parse(JSON.stringify(this.data));
  }

  getAll() {
    return this.snapshot();
  }

  load(obj) {
    if (!obj || typeof obj !== "object") return;
    this.data = { ...this.data, ...obj };
  }
}
