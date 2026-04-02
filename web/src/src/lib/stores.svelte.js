import { fetchNui, getMockBreeds, getMockPet, getMockActions, getMockTricks } from './nui.js';

const isDev = !window.GetParentResourceName;

/**
 * Main pet store — handles both Shop and Companion screens.
 * Uses Svelte 5 $state runes for reactivity.
 */
export function createPetStore() {
  // ---- Shared State ----
  let screen = $state(null);       // null | 'shop' | 'companion'
  let visible = $state(false);

  // ---- Shop State ----
  let breeds = $state([]);
  let selectedBreed = $state(null);
  let speciesFilter = $state('all');
  let searchQuery = $state('');
  let playerJob = $state('');
  let playerMoney = $state({ cash: 0, bank: 0 });
  let buyName = $state('');
  let buyVariation = $state(null);
  let variations = $state({});

  // ---- Companion State ----
  let pet = $state(null);
  let actions = $state([]);
  let tricks = $state([]);
  let otherPets = $state([]);
  let isGuarding = $state(false);
  let isAggroed = $state(false);
  let isK9Job = $state(false);
  let canSpecialize = $state(false);
  let specializations = $state({});
  let settings = $state({
    followDistance: 2.5,
    ambientAI: true,
    ownerReactions: true,
  });

  // ---- Derived ----
  let filteredBreeds = $derived(
    breeds.filter(b => {
      if (speciesFilter !== 'all' && b.species !== speciesFilter) return false;
      if (searchQuery && !b.label.toLowerCase().includes(searchQuery.toLowerCase())) return false;
      return true;
    })
  );

  // ---- Actions ----

  function openShop(payload) {
    breeds = payload.breeds || [];
    playerJob = payload.playerJob || '';
    playerMoney = payload.playerMoney || { cash: 0, bank: 0 };
    variations = payload.variations || {};
    selectedBreed = null;
    speciesFilter = 'all';
    searchQuery = '';
    buyName = '';
    buyVariation = null;

    // Pre-select breed if opened from display dog
    if (payload.preselectedItem) {
      selectedBreed = breeds.find(b => b.item === payload.preselectedItem) || null;
    }

    screen = 'shop';
    visible = true;
  }

  function openCompanion(payload) {
    pet = payload.pet || null;
    actions = payload.actions || [];
    tricks = payload.tricks || [];
    otherPets = payload.otherPets || [];
    isGuarding = payload.isGuarding || false;
    isAggroed = payload.isAggroed || false;
    isK9Job = payload.isK9Job || false;
    canSpecialize = payload.canSpecialize || false;
    specializations = payload.specializations || {};
    if (payload.settings) settings = { ...settings, ...payload.settings };

    screen = 'companion';
    visible = true;
  }

  function updatePetStats(payload) {
    if (!pet) return;
    if (payload.health !== undefined) pet.health = payload.health;
    if (payload.food !== undefined) pet.food = payload.food;
    if (payload.thirst !== undefined) pet.thirst = payload.thirst;
    if (payload.xp !== undefined) pet.xp = payload.xp;
    if (payload.level !== undefined) {
      pet.level = payload.level;
      if (payload.levelTitle) pet.levelTitle = payload.levelTitle;
    }
  }

  async function close() {
    visible = false;
    screen = null;
    selectedBreed = null;
    await fetchNui('nui:close');
  }

  // -- Shop actions --

  function selectBreed(breed) {
    selectedBreed = breed;
    buyName = '';
    buyVariation = null;
  }

  async function buyPet(paymentMethod) {
    if (!selectedBreed) return;
    const result = await fetchNui('nui:shopBuy', {
      breedItem: selectedBreed.item,
      name: buyName || null,
      variation: buyVariation || null,
      paymentMethod,
    });
    if (result?.success) {
      close();
    }
    return result;
  }

  // -- Companion actions --

  async function executeAction(actionType) {
    const result = await fetchNui('nui:companionAction', { action: actionType });
    // Update local state based on action
    if (actionType === 'Guard') isGuarding = !isGuarding;
    if (actionType === 'Aggro') isAggroed = !isAggroed;
    return result;
  }

  async function executeTrick(trickName) {
    return fetchNui('nui:companionTrick', { trick: trickName });
  }

  async function specialize(spec) {
    const result = await fetchNui('nui:specialize', { specialization: spec });
    if (result?.success && pet) {
      pet.specialization = spec;
      canSpecialize = false;
    }
    return result;
  }

  async function switchPet(hash) {
    return fetchNui('nui:switchPet', { hash });
  }

  async function updateSetting(key, value) {
    settings[key] = value;
    return fetchNui('nui:updateSetting', { key, value });
  }

  async function renamePet(name) {
    const result = await fetchNui('nui:renamePet', { hash: pet?.hash, name });
    if (result?.success && pet) pet.name = name;
    return result;
  }

  // -- Dev mode init --
  function initDev() {
    if (!isDev) return;
    // Auto-open companion for dev testing
    openCompanion({
      pet: getMockPet(),
      actions: getMockActions(),
      tricks: getMockTricks(),
      otherPets: [
        { hash: 'bC4yZ0mP3nQ6rT', name: 'Luna', level: 5, model: 'A_C_Pug', icon: 'dog', health: 280, maxHealth: 300 },
      ],
      isGuarding: false,
      isAggroed: false,
      isK9Job: false,
      canSpecialize: false,
      specializations: {
        guardian: { label: 'Guardian', desc: '1.5x guard radius, +50 combat', icon: 'shield' },
        tracker: { label: 'Tracker', desc: 'Detect peds within 50m', icon: 'magnifying-glass' },
        companion: { label: 'Companion', desc: '2x stress relief, 2x regen', icon: 'heart' },
      },
      settings: { followDistance: 2.5, ambientAI: true, ownerReactions: true },
    });
  }

  return {
    // State (getters)
    get screen() { return screen; },
    get visible() { return visible; },
    get breeds() { return breeds; },
    get filteredBreeds() { return filteredBreeds; },
    get selectedBreed() { return selectedBreed; },
    get speciesFilter() { return speciesFilter; },
    set speciesFilter(v) { speciesFilter = v; },
    get searchQuery() { return searchQuery; },
    set searchQuery(v) { searchQuery = v; },
    get playerJob() { return playerJob; },
    get playerMoney() { return playerMoney; },
    get buyName() { return buyName; },
    set buyName(v) { buyName = v; },
    get buyVariation() { return buyVariation; },
    set buyVariation(v) { buyVariation = v; },
    get variations() { return variations; },
    get pet() { return pet; },
    get actions() { return actions; },
    get tricks() { return tricks; },
    get otherPets() { return otherPets; },
    get isGuarding() { return isGuarding; },
    get isAggroed() { return isAggroed; },
    get isK9Job() { return isK9Job; },
    get canSpecialize() { return canSpecialize; },
    get specializations() { return specializations; },
    get settings() { return settings; },

    // Methods
    openShop,
    openCompanion,
    updatePetStats,
    close,
    selectBreed,
    buyPet,
    executeAction,
    executeTrick,
    specialize,
    switchPet,
    updateSetting,
    renamePet,
    initDev,
  };
}
