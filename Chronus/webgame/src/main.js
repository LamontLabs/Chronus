import Phaser from "phaser";
import BootScene from "./scenes/BootScene.js";
import GameScene from "./scenes/GameScene.js";
import UIScene from "./scenes/UIScene.js";

const width = 720;
const height = 1600;

const config = {
  type: Phaser.AUTO,
  parent: "app",
  width,
  height,
  backgroundColor: "#0b0f14",
  physics: { default: "arcade", arcade: { gravity: { y: 0 } } },
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
    width,
    height
  },
  fps: { target: 60, forceSetTimeOut: true },
  scene: [BootScene, GameScene, UIScene]
};

window.__CHRONUS__ = window.__CHRONUS__ || {};
window.__CHRONUS__.seed = 1337;

new Phaser.Game(config);
