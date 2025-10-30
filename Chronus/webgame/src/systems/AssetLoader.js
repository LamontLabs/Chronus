/**
 * AssetLoader - Loads all YAML/JSON game data from GitHub assets
 * Handles themes, world elements, economy, creatures, buildings, etc.
 */
import yaml from 'js-yaml';

export default class AssetLoader {
  constructor() {
    this.data = {
      // Core game data
      eras: null,
      palettes: null,
      lighting: null,
      resources: null,
      buildings: null,
      creatures: null,
      flora: null,
      relics: null,
      quests: null,
      worldZones: null,
      biomes: null,
      storyEvents: null,
      techTree: null,
      achievements: null,
      // Additional systems
      ui: null,
      particleEffects: null,
      automation: null,
      legacyTree: null,
      commerceSKU: null,
      pricing: null,
      worldEvents: null,
      crafting: null,
      researchTree: null,
      playerProfile: null,
      saveLogic: null,
      notifications: null,
      localization: null,
      soundMap: null,
      voiceLines: null,
      telemetry: null,
      psychology: null,
      security: null,
      buildingUpgrades: null,
      animationRules: null,
      mapRules: null,
      chronoshardEconomy: null,
      relicRecipes: null,
      progressionCurves: null,
      automationAgents: null,
      currencyBalance: null,
      eventRotation: null,
      contracts: null,
      menuLayout: null,
      fontStyles: null,
      tutorialSteps: null,
      colorPalette: null,
      retentionMetrics: null,
      reinforcement: null,
      fatigue: null,
      cadence: null,
      animationSequences: null,
      pricingRules: null,
      pricingBaseline: null
    };
    this.loaded = false;
  }

  /**
   * Load ALL game data files (all 54 YAML/JSON files)
   */
  async loadAll() {
    console.log('📦 Loading all Chronus assets...');
    
    try {
      // Load all files in parallel
      const results = await Promise.allSettled([
        // Core world & progression
        this.fetchJSON('/assets/world/era_timeline.json'),
        this.fetchYAML('/assets/color/era_palettes.yaml'),
        this.fetchYAML('/assets/lighting/lighting_profiles.yaml'),
        this.fetchYAML('/assets/world/story_events.yaml'),
        
        // Economy & resources
        this.fetchYAML('/assets/economy/resources.yaml'),
        this.fetchYAML('/assets/economy/crafting_recipes.yaml'),
        this.fetchJSON('/assets/economy/research_tree.json'),
        this.fetchJSON('/assets/economy/progression_curves.json'),
        this.fetchJSON('/assets/economy/automation_agents.json'),
        this.fetchYAML('/assets/economy/currency_balance.yaml'),
        
        // Buildings & architecture
        this.fetchYAML('/assets/buildings/architecture_catalog.yaml'),
        this.fetchJSON('/assets/buildings/upgrade_stages.json'),
        this.fetchJSON('/assets/buildings/animation_rules.json'),
        
        // Creatures & nature
        this.fetchYAML('/assets/fauna/creatures_catalog.yaml'),
        this.fetchYAML('/assets/flora/plant_catalog.yaml'),
        
        // Relics & artifacts
        this.fetchYAML('/assets/relics/relic_catalog.yaml'),
        this.fetchJSON('/assets/relics/relic_forge_recipes.json'),
        
        // Quests & achievements
        this.fetchYAML('/assets/quests/questlines.yaml'),
        this.fetchJSON('/assets/player/achievements.json'),
        
        // Maps & world
        this.fetchYAML('/assets/maps/world_zones.yaml'),
        this.fetchYAML('/assets/maps/biome_map.yaml'),
        this.fetchJSON('/assets/maps/map_rules.json'),
        
        // Research & tech
        this.fetchJSON('/assets/research/tech_tree.json'),
        
        // UI & interface
        this.fetchYAML('/assets/ui/interface_layout.yaml'),
        this.fetchYAML('/assets/ui/font_styles.yaml'),
        this.fetchYAML('/assets/ui/tutorial_steps.yaml'),
        this.fetchJSON('/assets/player/menus_layout.json'),
        
        // Visuals & effects
        this.fetchYAML('/assets/visuals/particle_effects.yaml'),
        this.fetchJSON('/assets/visuals/color_palette.json'),
        this.fetchYAML('/assets/animation/sequences.yaml'),
        this.fetchJSON('/assets/shaders/shader_manifest.json'),
        
        // Automation
        this.fetchYAML('/assets/automation/automation_rules.yaml'),
        
        // Legacy & meta
        this.fetchYAML('/assets/legacy_tree/legacy_nodes.yaml'),
        this.fetchYAML('/assets/legacy/chronoshard_economy.yaml'),
        
        // Commerce & monetization
        this.fetchJSON('/assets/commerce/sku_catalog.json'),
        this.fetchJSON('/assets/commerce/pricing.json'),
        this.fetchJSON('/assets/commerce/pricing_rules.json'),
        this.fetchJSON('/assets/commerce/pricing_baseline.json'),
        
        // Events & live ops
        this.fetchYAML('/assets/events/world_events.yaml'),
        this.fetchJSON('/assets/events/rotation.json'),
        this.fetchJSON('/assets/events/contracts.json'),
        
        // Player systems
        this.fetchJSON('/assets/player/profile_schema.json'),
        this.fetchYAML('/assets/player/save_logic.yaml'),
        this.fetchYAML('/assets/player/notifications.yaml'),
        this.fetchYAML('/assets/player/push_templates.yaml'),
        
        // Audio
        this.fetchYAML('/assets/audio/sound_map.yaml'),
        this.fetchJSON('/assets/audio/voice_lines_archive7.json'),
        
        // Localization
        this.fetchJSON('/assets/localization/strings_en.json'),
        
        // Analytics & psychology
        this.fetchJSON('/assets/telemetry/metrics_schema.json'),
        this.fetchYAML('/assets/psychology/retention_metrics.yaml'),
        this.fetchYAML('/assets/psychology/reinforcement_layers.yaml'),
        this.fetchYAML('/assets/psychology/fatigue_rules.yaml'),
        this.fetchJSON('/assets/psychology/cadence_schedule.json'),
        
        // Security
        this.fetchYAML('/assets/security/security_policies.yaml')
      ]);

      // Map results to data structure
      let i = 0;
      this.data.eras = this.getValue(results[i++]);
      this.data.palettes = this.getValue(results[i++])?.palettes || {};
      this.data.lighting = this.getValue(results[i++])?.profiles || {};
      this.data.storyEvents = this.getValue(results[i++])?.chapters || [];
      
      this.data.resources = this.getValue(results[i++])?.resources || [];
      this.data.crafting = this.getValue(results[i++])?.recipes || [];
      this.data.researchTree = this.getValue(results[i++])?.technologies || [];
      this.data.progressionCurves = this.getValue(results[i++]);
      this.data.automationAgents = this.getValue(results[i++]);
      this.data.currencyBalance = this.getValue(results[i++]);
      
      this.data.buildings = this.getValue(results[i++])?.buildings || [];
      this.data.buildingUpgrades = this.getValue(results[i++]);
      this.data.animationRules = this.getValue(results[i++]);
      
      this.data.creatures = this.getValue(results[i++])?.categories || {};
      this.data.flora = this.getValue(results[i++])?.flora || [];
      
      this.data.relics = this.getValue(results[i++])?.relics || [];
      this.data.relicRecipes = this.getValue(results[i++]);
      
      this.data.quests = this.getValue(results[i++])?.questlines || [];
      this.data.achievements = this.getValue(results[i++])?.achievements || [];
      
      this.data.worldZones = this.getValue(results[i++])?.zones || [];
      this.data.biomes = this.getValue(results[i++])?.biomes || [];
      this.data.mapRules = this.getValue(results[i++]);
      
      this.data.techTree = this.getValue(results[i++])?.technologies || [];
      
      this.data.ui = this.getValue(results[i++]);
      this.data.fontStyles = this.getValue(results[i++]);
      this.data.tutorialSteps = this.getValue(results[i++]);
      this.data.menuLayout = this.getValue(results[i++]);
      
      this.data.particleEffects = this.getValue(results[i++])?.effects || {};
      this.data.colorPalette = this.getValue(results[i++]);
      this.data.animationSequences = this.getValue(results[i++]);
      const shaders = this.getValue(results[i++]);
      
      this.data.automation = this.getValue(results[i++])?.rules || [];
      
      this.data.legacyTree = this.getValue(results[i++])?.nodes || [];
      this.data.chronoshardEconomy = this.getValue(results[i++]);
      
      this.data.commerceSKU = this.getValue(results[i++]);
      this.data.pricing = this.getValue(results[i++]);
      this.data.pricingRules = this.getValue(results[i++]);
      this.data.pricingBaseline = this.getValue(results[i++]);
      
      this.data.worldEvents = this.getValue(results[i++]);
      this.data.eventRotation = this.getValue(results[i++]);
      this.data.contracts = this.getValue(results[i++]);
      
      this.data.playerProfile = this.getValue(results[i++]);
      this.data.saveLogic = this.getValue(results[i++]);
      this.data.notifications = this.getValue(results[i++]);
      const pushTemplates = this.getValue(results[i++]);
      
      this.data.soundMap = this.getValue(results[i++]);
      this.data.voiceLines = this.getValue(results[i++]);
      
      this.data.localization = this.getValue(results[i++]);
      
      this.data.telemetry = this.getValue(results[i++]);
      this.data.retentionMetrics = this.getValue(results[i++]);
      this.data.reinforcement = this.getValue(results[i++]);
      this.data.fatigue = this.getValue(results[i++]);
      this.data.cadence = this.getValue(results[i++]);
      
      this.data.security = this.getValue(results[i++]);

      this.loaded = true;
      
      // Log summary
      const loaded = results.filter(r => r.status === 'fulfilled').length;
      const failed = results.filter(r => r.status === 'rejected').length;
      console.log(`✅ Loaded ${loaded}/${results.length} asset files (${failed} fallback)`);
      console.log('📊 Content Summary:', {
        eras: Object.keys(this.data.palettes).length,
        resources: this.data.resources.length,
        buildings: this.data.buildings.length,
        creatures: Object.values(this.data.creatures).flat().length,
        flora: this.data.flora.length,
        quests: this.data.quests.length,
        relics: this.data.relics.length,
        worldZones: this.data.worldZones.length,
        biomes: this.data.biomes.length
      });
      
      return this.data;
    } catch (error) {
      console.error('❌ Error loading assets:', error);
      return this.getFallbackData();
    }
  }

  getValue(result) {
    return result.status === 'fulfilled' ? result.value : null;
  }

  /**
   * Fetch JSON file
   */
  async fetchJSON(path) {
    const response = await fetch(path);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return await response.json();
  }

  /**
   * Fetch YAML file using js-yaml library
   */
  async fetchYAML(path) {
    const response = await fetch(path);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const text = await response.text();
    return yaml.load(text);
  }

  /**
   * Fallback data if files can't be loaded
   */
  getFallbackData() {
    return {
      eras: [
        { id: 'fire', name: 'Fire Age' },
        { id: 'stone', name: 'Stone Age' },
        { id: 'bronze', name: 'Bronze Age' },
        { id: 'iron', name: 'Iron Age' },
        { id: 'industrial', name: 'Industrial Age' },
        { id: 'digital', name: 'Digital Age' },
        { id: 'quantum', name: 'Quantum Age' },
        { id: 'ascension', name: 'Ascension' }
      ],
      palettes: {
        fire: { primary: '#FF7043', secondary: '#FFD54F', accent: '#8D6E63' }
      },
      resources: [
        { id: 'energy', tier: 1, baseRate: 0.05 }
      ]
    };
  }

  // Accessor methods
  getPalette(eraId) {
    return this.data.palettes[eraId] || this.data.palettes.fire;
  }

  getLighting(eraId) {
    return this.data.lighting[eraId] || this.data.lighting.fire;
  }

  getResources() {
    return this.data.resources;
  }

  getBuildings(eraId) {
    return this.data.buildings.filter(b => !b.era || b.era === eraId);
  }

  getCreatures(biomeId) {
    const all = Object.values(this.data.creatures).flat();
    return all.filter(c => !biomeId || c.biome === biomeId);
  }
}
