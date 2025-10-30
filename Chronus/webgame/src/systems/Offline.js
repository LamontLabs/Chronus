export default class Offline {
  constructor(saveSystem, economy, state) {
    this.save = saveSystem;
    this.eco = economy;
    this.s = state;
  }

  applyOnBoot() {
    const loaded = this.save.load();
    const lastTs = loaded?.ts || Date.now();
    return this.eco.computeOfflineGain(lastTs);
  }
}
