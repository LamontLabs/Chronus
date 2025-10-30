import State from "../systems/State.js";
import SaveSystem from "../systems/SaveSystem.js";
import Economy from "../systems/Economy.js";
import Offline from "../systems/Offline.js";
import GameData from "../systems/GameData.js";
import { formatNum } from "../utils/math.js";

export default class GameScene extends Phaser.Scene {
  constructor() {
    super("GameScene");
  }

  preload() {
    this.load.image("bg", "assets/bg_fire.png");
    this.load.image("spark", "assets/spark.png");
  }

  async create() {
    this.state = new State();
    this.save = new SaveSystem(this.state);
    this.economy = new Economy(this.state);
    this.offline = new Offline(this.save, this.economy, this.state);

    this.offlineGain = this.offline.applyOnBoot();
    this.save.startAutoSave(this);

    // Apply theme from loaded data
    const theme = GameData.getTheme();
    const bgColor = parseInt(theme.background.replace('#', '0x'));
    this.cameras.main.setBackgroundColor(bgColor);

    this.bg = this.add.image(540, 960, "bg").setDisplaySize(1080, 1920);
    this.bg.setTint(parseInt(theme.colors.primary.replace('#', '0x')));
    
    this.resources = this.add.text(60, 60, "", { 
      fontSize: "36px", 
      fill: theme.colors.secondary || "#FFD54F" 
    });
    
    // Display loaded content count
    this.contentInfo = this.add.text(60, 120, "", {
      fontSize: "20px",
      fill: theme.colors.accent || "#a0a0a0"
    });
    this.updateContentInfo();
    
    this.lastTick = Date.now();

    this.input.on("pointerdown", () => this.collectEnergy());
    
    console.log('🎮 Game running with theme:', theme.era);
  }

  update() {
    const now = Date.now();
    const dt = (now - this.lastTick) / 1000;
    this.economy.tick(dt);
    this.renderResources();
    this.lastTick = now;
  }

  renderResources() {
    const e = this.state.read("energy");
    const f = this.state.read("food");
    const m = this.state.read("metal");
    const c = this.state.read("chronoshards");
    this.resources.setText(
      `⚡ ${formatNum(e)}   🌾 ${formatNum(f)}   ⛏️ ${formatNum(m)}   💠 ${formatNum(c)}`
    );
  }

  collectEnergy() {
    const theme = GameData.getTheme();
    const part = this.add.particles("spark");
    const emitter = part.createEmitter({
      x: 540,
      y: 960,
      speed: { min: -300, max: 300 },
      lifespan: 300,
      quantity: 12,
      tint: parseInt(theme.particles.replace('#', '0x'))
    });
    this.state.add("energy", 5);
    this.time.delayedCall(400, () => part.destroy());
  }

  updateContentInfo() {
    const resources = GameData.getResources();
    const buildings = GameData.getBuildings();
    const zones = GameData.getWorldZones();
    const quests = GameData.getQuests();
    
    this.contentInfo.setText(
      `Resources: ${resources.length} | Buildings: ${buildings.length} | Zones: ${zones.length} | Quests: ${quests.length}`
    );
  }
}
