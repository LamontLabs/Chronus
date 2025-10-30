export default class UIScene extends Phaser.Scene {
  constructor() {
    super("UIScene");
  }

  async create() {
    this.title = this.add.text(540, 100, "Chronus", {
      fontSize: "56px",
      fontFamily: "Orbitron",
      color: "#FFD54F"
    }).setOrigin(0.5);

    this.subtitle = this.add.text(540, 180, "Offline Civilization Builder", {
      fontSize: "20px",
      fontFamily: "Inter",
      color: "#90A4AE"
    }).setOrigin(0.5);

    this.prestigeButton = this.add.text(540, 1800, "Prestige", {
      fontSize: "42px",
      fontFamily: "Inter",
      color: "#FFF176",
      backgroundColor: "#212121",
      padding: { x: 20, y: 10 }
    })
      .setOrigin(0.5)
      .setInteractive({ useHandCursor: true })
      .on("pointerdown", () => {
        this.scene.get("GameScene").economy.prestige();
        this.flashMessage("Civilization reset. Legacy grows.");
      });

    this.flash = this.add.text(540, 900, "", {
      fontSize: "42px",
      color: "#FFFFFF",
      fontFamily: "Orbitron"
    }).setOrigin(0.5);
  }

  flashMessage(msg) {
    this.flash.setText(msg);
    this.tweens.add({
      targets: this.flash,
      alpha: { from: 1, to: 0 },
      duration: 2000,
      onComplete: () => this.flash.setText("")
    });
  }
}
