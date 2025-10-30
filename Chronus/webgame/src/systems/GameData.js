/**
 * GameData - Central repository for all loaded game content
 * Provides easy access to themes, world elements, economy data, etc.
 */
import AssetLoader from './AssetLoader.js';

class GameData {
  constructor() {
    this.loader = new AssetLoader();
    this.currentEra = 'fire';
    this.ready = false;
  }

  /**
   * Initialize and load all game data
   */
  async initialize() {
    console.log('🎮 Loading Chronus game data...');
    await this.loader.loadAll();
    this.ready = true;
    console.log('✅ Game data ready!');
    return this;
  }

  /**
   * Get current theme colors
   */
  getTheme() {
    const palette = this.loader.getPalette(this.currentEra);
    const lighting = this.loader.getLighting(this.currentEra);
    
    return {
      era: this.currentEra,
      colors: palette,
      lighting: lighting,
      background: this.getBackgroundColor(),
      particles: this.getParticleColor()
    };
  }

  /**
   * Get background color for current era
   */
  getBackgroundColor() {
    const eraColors = {
      fire: '#1a0e08',
      stone: '#1f1f1f',
      bronze: '#2d2416',
      iron: '#1c2127',
      industrial: '#0d1117',
      digital: '#0a1929',
      quantum: '#1a0d2e',
      ascension: '#f5f5dc'
    };
    return eraColors[this.currentEra] || '#0b0f14';
  }

  /**
   * Get particle color for current era
   */
  getParticleColor() {
    const palette = this.loader.getPalette(this.currentEra);
    return palette.secondary || '#FFD54F';
  }

  /**
   * Get all eras
   */
  getEras() {
    return this.loader.data.eras || this.loader.getFallbackData().eras;
  }

  /**
   * Get era info
   */
  getEra(eraId) {
    const eras = this.getEras();
    return eras.find(e => e.id === eraId) || eras[0];
  }

  /**
   * Set current era
   */
  setEra(eraId) {
    this.currentEra = eraId;
    console.log(`🌍 Era changed to: ${eraId}`);
  }

  /**
   * Get resources data
   */
  getResources() {
    return this.loader.getResources();
  }

  /**
   * Get buildings
   */
  getBuildings(eraId = null) {
    return this.loader.getBuildings(eraId || this.currentEra);
  }

  /**
   * Get creatures
   */
  getCreatures(biomeId = 'forest') {
    return this.loader.getCreatures(biomeId);
  }

  /**
   * Get world zones
   */
  getWorldZones() {
    return this.loader.data.worldZones || [];
  }

  /**
   * Get biomes
   */
  getBiomes() {
    return this.loader.data.biomes || [];
  }

  /**
   * Get quests
   */
  getQuests() {
    return this.loader.data.quests || [];
  }

  /**
   * Get relics
   */
  getRelics() {
    return this.loader.data.relics || [];
  }

  /**
   * Get tech tree
   */
  getTechTree() {
    return this.loader.data.techTree || [];
  }

  /**
   * Get achievements
   */
  getAchievements() {
    return this.loader.data.achievements || [];
  }

  /**
   * Get story events for era
   */
  getStoryEvents(eraId = null) {
    const era = eraId || this.currentEra;
    const chapters = this.loader.data.storyEvents || [];
    const chapter = chapters.find(c => c.era?.toLowerCase().includes(era));
    return chapter?.events || [];
  }

  /**
   * Get particle effects
   */
  getParticleEffects() {
    return this.loader.data.particleEffects || {};
  }

  /**
   * Get UI layout
   */
  getUILayout() {
    return this.loader.data.ui || {};
  }

  /**
   * Get all loaded data (for debugging)
   */
  getAllData() {
    return this.loader.data;
  }
}

// Export singleton instance
export default new GameData();
