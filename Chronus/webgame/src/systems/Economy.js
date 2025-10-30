import { clamp } from "../utils/math.js";

export default class Economy {
  constructor(state) {
    this.s = state;
    this.rates = {
      energy: 0.5,
      food: 0.1,
      wood: 0.1,
      stone: 0.1,
      metal: 0.05,
      knowledge: 0.02
    };
    this.offlineCapH = 12;
  }

  tick(dt) {
    const mult = (1 + this.s.read("legacy", 0));
    const auto = this.s.read("automation", 1);
    const factor = mult * auto;

    for (const k of Object.keys(this.rates)) {
      const gain = this.rates[k] * factor * dt;
      this.s.add(k, gain);
    }
    return factor;
  }

  computeOfflineGain(lastTs) {
    const hours = clamp((Date.now() - lastTs) / 3.6e6, 0, this.offlineCapH);
    const mult = (1 + this.s.read("legacy", 0));
    const auto = this.s.read("automation", 1);
    const factor = mult * auto;
    const gains = {};
    for (const k of Object.keys(this.rates)) {
      const gain = this.rates[k] * factor * (hours * 3600) * 0.9;
      gains[k] = gain;
      this.s.add(k, gain);
    }
    return { hours, gains };
  }

  prestige() {
    const p = this.s.add("prestige", 1);
    const legacyBonus = Math.pow(1.5, p) * 0.1;
    this.s.write("legacy", this.s.read("legacy") + legacyBonus);
    this.s.write("energy", 10);
    this.s.write("knowledge", 0);
    this.s.add("artifacts", 1);
    return { p, legacyBonus };
  }
}
