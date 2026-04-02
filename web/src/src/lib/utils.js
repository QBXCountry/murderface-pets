/**
 * Format a number as a price string: $12,000
 */
export function formatPrice(n) {
  return '$' + Math.floor(n).toLocaleString('en-US');
}

/**
 * Get pet breed image URL from ox_inventory
 * Falls back to a paw icon SVG data URI on 404
 */
export function getBreedImageUrl(itemName) {
  return `nui://ox_inventory/web/images/${itemName}.png`;
}

/**
 * SVG fallback for missing pet images (paw icon)
 */
export const PAW_FALLBACK = `data:image/svg+xml,${encodeURIComponent(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" fill="rgba(140,140,145,0.4)"><path d="M226.5 92.9c14.3 42.9-.3 86.2-32.6 96.8s-70.1-15.6-84.4-58.5c-14.3-42.9.3-86.2 32.6-96.8 32.4-10.6 70.2 15.6 84.4 58.5zM100.4 198.6c18.9 32.4 14.3 70.1-10.2 84.1s-59.7-.9-78.5-33.3C-7.2 217.1-2.6 179.3 21.9 165.3s59.6.9 78.5 33.3zM69.2 401.2C121.6 259.9 214.7 224 256 224s134.4 35.9 186.8 177.2c3.6 9.7 5.2 20.1 5.2 30.5v1.6c0 25.8-20.9 46.7-46.7 46.7-11.5 0-22.9-1.4-34-4.2l-88-22c-15.3-3.8-31.3-3.8-46.6 0l-88 22c-11.1 2.8-22.5 4.2-34 4.2-25.8 0-46.7-20.9-46.7-46.7v-1.6c0-10.4 1.6-20.8 5.2-30.5zM411.6 198.6c18.9-32.4 54.1-57.6 78.5-33.3 24.5 24.3 29.1 52.1 10.2 84.1-18.9 32.4-54.1 57.6-78.5 33.3-24.5-14.1-29.1-51.8-10.2-84.1zM285.5 92.9c14.3-42.9 52.1-69.1 84.4-58.5 32.4 10.6 46.9 53.9 32.6 96.8-14.3 42.9-52.1 69.1-84.4 58.5-32.3-10.6-46.9-53.9-32.6-96.8z"/></svg>`)}`;

/**
 * Calculate XP percentage for progress bar
 */
export function xpPercent(xp, xpNeeded) {
  if (!xpNeeded || xpNeeded <= 0) return 100;
  return Math.min(100, Math.round((xp / xpNeeded) * 100));
}

/**
 * Get species icon name (Font Awesome style)
 */
export function speciesIcon(species) {
  const icons = {
    dog: 'dog',
    cat: 'cat',
    wild: 'paw',
    bird: 'dove',
    primate: 'hand',
    rabbit: 'rabbit',
  };
  return icons[species] || 'paw';
}

/**
 * Get size label color
 */
export function sizeColor(size) {
  const colors = {
    small: 'var(--green)',
    medium: 'var(--gold)',
    large: 'var(--accent)',
  };
  return colors[size] || 'var(--text-secondary)';
}
