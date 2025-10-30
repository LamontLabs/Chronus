import Phaser from "phaser";
import GameData from "../systems/GameData.js";

export default class BootScene extends Phaser.Scene {
  constructor() {
    super("Boot");
  }

  create() {
    // Show loading text
    const loadingText = this.add.text(360, 800, "Loading Chronus data...", {
      fontFamily: "monospace",
      fontSize: 24,
      color: "#FFD54F"
    }).setOrigin(0.5);

    // Initialize game data
    GameData.initialize().then(() => {
      console.log('📦 All game data loaded:', GameData.getAllData());
      
      // Show summary
      const data = GameData.getAllData();
      const summary = [
        `✅ ${Object.keys(data.palettes).length} Era Themes`,
        `✅ ${data.resources.length} Resources`,
        `✅ ${data.worldZones.length} World Zones`,
        `✅ ${data.quests.length} Quest Lines`,
        `✅ ${data.relics.length} Relics`
      ];
      
      loadingText.setText(summary.join('\n'));
      
      // Start game directly (offline mode)
      this.time.delayedCall(1500, () => {
        this.scene.start("GameScene");
      });
    }).catch(err => {
      console.error('Failed to load game data:', err);
      loadingText.setText('Starting with fallback data...');
      this.time.delayedCall(1000, () => {
        this.scene.start("GameScene");
      });
    });
  }
}
