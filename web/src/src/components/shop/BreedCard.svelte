<script>
  import { formatPrice, getBreedImageUrl, PAW_FALLBACK, sizeColor } from '../../lib/utils.js';

  let { breed, selected = false, locked = false, onclick = () => {} } = $props();
</script>

<button class="breed-card" class:selected class:locked {onclick}>
  <div class="card-img">
    <img
      src={getBreedImageUrl(breed.item)}
      alt={breed.label}
      onerror={(e) => e.target.src = PAW_FALLBACK}
    />
    {#if locked}
      <div class="lock-overlay">Restricted</div>
    {/if}
  </div>
  <div class="card-info">
    <div class="card-name">{breed.label}</div>
    <div class="card-meta">
      <span class="card-species">{breed.species}</span>
      <span class="card-size" style="color: {sizeColor(breed.size)}">{breed.size}</span>
    </div>
    <div class="card-price">{formatPrice(breed.price)}</div>
  </div>
</button>

<style>
  .breed-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    overflow: hidden;
    cursor: pointer;
    text-align: left;
    font-family: var(--font);
    transition: all 0.15s;
    display: flex;
    flex-direction: column;
  }
  .breed-card:hover {
    border-color: var(--border-hover);
    background: var(--bg-card-hover);
    transform: translateY(-2px);
  }
  .breed-card.selected {
    border-color: var(--accent-border);
    background: var(--bg-card-selected);
    box-shadow: 0 0 16px var(--accent-glow);
  }
  .breed-card.locked { opacity: 0.6; }

  .card-img {
    width: 100%;
    aspect-ratio: 1;
    background: rgba(0, 0, 0, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    overflow: hidden;
  }
  .card-img img {
    width: 75%;
    height: 75%;
    object-fit: contain;
  }

  .lock-overlay {
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    font-weight: 700;
    color: var(--red);
    text-transform: uppercase;
    letter-spacing: 1px;
  }

  .card-info {
    padding: 8px 10px 10px;
  }
  .card-name {
    font-size: 13px;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 3px;
  }
  .card-meta {
    display: flex;
    gap: 6px;
    margin-bottom: 4px;
  }
  .card-species, .card-size {
    font-size: 10px;
    font-weight: 600;
    text-transform: capitalize;
    color: var(--text-muted);
  }
  .card-price {
    font-size: 14px;
    font-weight: 700;
    color: var(--green);
  }
</style>
