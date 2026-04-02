/**
 * NUI Communication Layer for murderface-pets
 * Handles fetch calls to Lua backend and incoming window messages.
 */

const isDev = !window.GetParentResourceName;

function getResourceName() {
  if (isDev) return 'murderface-pets';
  return window.GetParentResourceName();
}

/**
 * Send a NUI callback to the Lua backend.
 * @param {string} event - callback name (e.g. 'nui:shopBuy')
 * @param {any} data - payload to send
 * @returns {Promise<any>} - response from Lua
 */
export async function fetchNui(event, data = {}) {
  if (isDev) {
    console.log(`[NUI DEV] ${event}`, data);
    return getMockResponse(event, data);
  }

  const url = `https://${getResourceName()}/${event}`;
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    return await response.json();
  } catch {
    return null;
  }
}

/**
 * Listen for NUI messages from the Lua backend.
 * @param {string} type - message type (e.g. 'openShop', 'openCompanion')
 * @param {function} handler - callback function
 * @returns {function} - cleanup function to remove listener
 */
export function onNuiMessage(type, handler) {
  const listener = (event) => {
    if (event.data?.type === type) {
      handler(event.data.payload || event.data);
    }
  };
  window.addEventListener('message', listener);
  return () => window.removeEventListener('message', listener);
}

/**
 * Dev mode: mock responses for browser testing without FiveM
 */
function getMockResponse(event, data) {
  switch (event) {
    case 'nui:close':
      return 'ok';

    case 'nui:shopBuy':
      return { success: true, message: 'Husky' };

    case 'nui:companionAction':
      return { success: true, message: `${data.action} executed` };

    case 'nui:companionTrick':
      return { success: true };

    case 'nui:specialize':
      return { success: true, message: `Specialized as ${data.specialization}` };

    case 'nui:switchPet':
      return 'ok';

    case 'nui:updateSetting':
      return 'ok';

    case 'nui:renamePet':
      return { success: true };

    default:
      return 1;
  }
}

/**
 * Dev mode: generate mock data for testing
 */
export function getMockBreeds() {
  return [
    { item: 'murderface_husky', label: 'Husky', model: 'A_C_Husky', price: 12000, species: 'dog', size: 'large', maxHealth: 700, canHunt: true, canTrick: true, isK9: false, icon: 'dog', jobRestricted: null },
    { item: 'murderface_shepherd', label: 'German Shepherd', model: 'A_C_shepherd', price: 14000, species: 'dog', size: 'large', maxHealth: 800, canHunt: true, canTrick: true, isK9: false, icon: 'dog', jobRestricted: null },
    { item: 'murderface_rottweiler', label: 'Rottweiler', model: 'A_C_Rottweiler', price: 10000, species: 'dog', size: 'large', maxHealth: 750, canHunt: true, canTrick: true, isK9: false, icon: 'dog', jobRestricted: null },
    { item: 'murderface_pug', label: 'Pug', model: 'A_C_Pug', price: 4000, species: 'dog', size: 'small', maxHealth: 300, canHunt: false, canTrick: true, isK9: false, icon: 'dog', jobRestricted: null },
    { item: 'murderface_poodle', label: 'Poodle', model: 'a_c_poodle', price: 5000, species: 'dog', size: 'small', maxHealth: 350, canHunt: false, canTrick: true, isK9: false, icon: 'dog', jobRestricted: null },
    { item: 'murderface_cat', label: 'Cat', model: 'A_C_Cat_01', price: 3000, species: 'cat', size: 'small', maxHealth: 200, canHunt: false, canTrick: false, isK9: false, icon: 'cat', jobRestricted: null },
    { item: 'murderface_mtlion', label: 'Mountain Lion', model: 'A_C_MtLion', price: 35000, species: 'wild', size: 'large', maxHealth: 900, canHunt: true, canTrick: false, isK9: false, icon: 'paw-claws', jobRestricted: null },
    { item: 'murderface_k9', label: 'Police K9', model: 'pdk9', price: 0, species: 'dog', size: 'large', maxHealth: 900, canHunt: true, canTrick: true, isK9: true, icon: 'shield-dog', jobRestricted: ['police', 'lspd', 'bcso'] },
  ];
}

export function getMockPet() {
  return {
    hash: 'aB3xY9kL2mN5pQ',
    name: 'Rex',
    level: 12,
    xp: 4200,
    xpNeeded: 7200,
    health: 650,
    maxHealth: 700,
    food: 72,
    thirst: 30,
    specialization: null,
    species: 'dog',
    size: 'large',
    animClass: 'large_dog',
    canHunt: true,
    canTrick: true,
    canPet: true,
    isK9: false,
    icon: 'dog',
    model: 'A_C_Husky',
    levelTitle: 'Veteran',
  };
}

export function getMockActions() {
  return [
    { type: 'Follow', label: 'Follow', icon: 'person-walking', available: true },
    { type: 'Wait', label: 'Stay', icon: 'hand', available: true },
    { type: 'Hunt', label: 'Hunt', icon: 'crosshairs', available: true },
    { type: 'HuntGrab', label: 'Hunt & Grab', icon: 'hand-fist', available: true },
    { type: 'GoThere', label: 'Go There', icon: 'location-dot', available: true },
    { type: 'Guard', label: 'Guard', icon: 'shield', available: true },
    { type: 'Aggro', label: 'Aggro', icon: 'bolt', available: true },
    { type: 'Carry', label: 'Carry', icon: 'hands-holding', available: false },
    { type: 'Leash', label: 'Leash', icon: 'link', available: true },
    { type: 'GetInCar', label: 'Get in Car', icon: 'car', available: true },
  ];
}

export function getMockTricks() {
  return [
    { name: 'sit', label: 'Sit', icon: 'chair', requiredLevel: 0, locked: false },
    { name: 'beg', label: 'Beg', icon: 'hands-praying', requiredLevel: 5, locked: false },
    { name: 'paw', label: 'Paw', icon: 'hand', requiredLevel: 10, locked: false },
    { name: 'playDead', label: 'Play Dead', icon: 'skull', requiredLevel: 20, locked: true },
  ];
}
