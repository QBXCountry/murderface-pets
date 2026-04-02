<script>
  import { formatPrice, getBreedImageUrl, PAW_FALLBACK, sizeColor } from '../lib/utils.js';
  import BreedCard from '../components/shop/BreedCard.svelte';

  let { store } = $props();
</script>

<div class="shop-panel">
  <div class="shop-header">
    <h2>Pet Shop</h2>
    <button class="close-btn" onclick={() => store.close()}>x</button>
  </div>

  <!-- Species filters -->
  <div class="filters">
    {#each ['all', 'dog', 'cat', 'wild'] as species}
      <button
        class="filter-pill" class:active={store.speciesFilter === species}
        onclick={() => store.speciesFilter = species}
      >{species === 'all' ? 'All' : species.charAt(0).toUpperCase() + species.slice(1) + 's'}</button>
    {/each}
  </div>

  <!-- Search -->
  <div class="search-wrap">
    <input
      class="search-input"
      type="text"
      placeholder="Search breeds..."
      value={store.searchQuery}
      oninput={(e) => store.searchQuery = e.target.value}
    />
  </div>

  <div class="shop-body">
    <!-- Breed Grid -->
    <div class="breed-grid">
      {#each store.filteredBreeds as breed (breed.item)}
        <BreedCard
          {breed}
          selected={store.selectedBreed?.item === breed.item}
          locked={breed.jobRestricted && !breed.jobRestricted.includes(store.playerJob)}
          onclick={() => store.selectBreed(breed)}
        />
      {/each}
      {#if store.filteredBreeds.length === 0}
        <div class="empty">No breeds found</div>
      {/if}
    </div>

    <!-- Detail Panel -->
    {#if store.selectedBreed}
      {@const b = store.selectedBreed}
      {@const locked = b.jobRestricted && !b.jobRestricted.includes(store.playerJob)}
      <div class="detail-panel">
        <div class="detail-img-wrap">
          <img
            src={getBreedImageUrl(b.item)}
            alt={b.label}
            onerror={(e) => e.target.src = PAW_FALLBACK}
          />
        </div>
        <h3>{b.label}</h3>
        <div class="detail-price">{formatPrice(b.price)}</div>

        <div class="detail-tags">
          <span class="tag" style="color: {sizeColor(b.size)}">{b.size}</span>
          <span class="tag">{b.species}</span>
          {#if b.canHunt}<span class="tag hunt">Hunt</span>{/if}
          {#if b.canTrick}<span class="tag trick">Tricks</span>{/if}
          {#if b.isK9}<span class="tag k9">K9</span>{/if}
        </div>

        <div class="detail-stats">
          <div class="stat-row"><span>Max Health</span><span>{b.maxHealth}</span></div>
          <div class="stat-row"><span>Size</span><span>{b.size}</span></div>
          <div class="stat-row"><span>Species</span><span>{b.species}</span></div>
        </div>

        {#if locked}
          <div class="locked-notice">Restricted — {b.jobRestricted.join(', ')} only</div>
        {:else}
          <!-- Name input -->
          <input
            class="name-input"
            type="text"
            placeholder="Name your pet (optional)"
            maxlength="20"
            value={store.buyName}
            oninput={(e) => store.buyName = e.target.value}
          />

          <!-- Buy buttons -->
          <div class="buy-buttons">
            <button class="buy-btn cash" onclick={() => store.buyPet('cash')}>
              Cash {formatPrice(b.price)}
            </button>
            <button class="buy-btn bank" onclick={() => store.buyPet('bank')}>
              Bank {formatPrice(b.price)}
            </button>
          </div>

          <div class="balance">
            Cash: {formatPrice(store.playerMoney.cash)} | Bank: {formatPrice(store.playerMoney.bank)}
          </div>
        {/if}
      </div>
    {/if}
  </div>
</div>

<style>
  .shop-panel {
    width: 900px;
    max-height: 85vh;
    background: var(--bg-panel);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
  }

  .shop-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid var(--border);
  }
  .shop-header h2 {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-primary);
  }
  .close-btn {
    width: 28px; height: 28px; border-radius: 6px;
    background: transparent; border: 1px solid var(--border);
    color: var(--text-muted); font-size: 14px; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    font-family: var(--font); transition: all 0.15s;
  }
  .close-btn:hover { color: var(--red); border-color: var(--red-border); background: var(--red-dim); }

  .filters {
    display: flex; gap: 8px; padding: 12px 20px 0;
  }
  .filter-pill {
    padding: 6px 16px; border-radius: var(--radius-pill);
    background: var(--bg-card); border: 1px solid var(--border);
    color: var(--text-secondary); font-size: 12px; font-weight: 600;
    font-family: var(--font); cursor: pointer; transition: all 0.15s;
  }
  .filter-pill:hover { border-color: var(--border-hover); color: var(--text-primary); }
  .filter-pill.active { background: var(--accent-dim); border-color: var(--accent-border); color: var(--accent); }

  .search-wrap { padding: 10px 20px 0; }
  .search-input {
    width: 100%; padding: 8px 12px;
    background: var(--bg-input); border: 1px solid var(--border);
    border-radius: var(--radius-sm); color: var(--text-primary);
    font-size: 12px; font-family: var(--font); outline: none;
  }
  .search-input:focus { border-color: var(--accent-border); }
  .search-input::placeholder { color: var(--text-muted); }

  .shop-body {
    display: flex; flex: 1; overflow: hidden; padding: 14px 20px 20px;
    gap: 16px;
  }

  .breed-grid {
    flex: 1;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 10px;
    overflow-y: auto;
    align-content: start;
  }
  .empty { grid-column: 1 / -1; text-align: center; color: var(--text-muted); padding: 40px; font-size: 13px; }

  /* Detail panel */
  .detail-panel {
    width: 280px;
    flex-shrink: 0;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 16px;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 10px;
    animation: slideIn 0.15s ease-out;
  }
  @keyframes slideIn { from { opacity: 0; transform: translateX(10px); } to { opacity: 1; transform: none; } }

  .detail-img-wrap {
    width: 100%; aspect-ratio: 1; background: rgba(0,0,0,0.3);
    border-radius: var(--radius-sm); overflow: hidden;
    display: flex; align-items: center; justify-content: center;
  }
  .detail-img-wrap img { width: 80%; height: 80%; object-fit: contain; }

  .detail-panel h3 { font-size: 16px; font-weight: 700; }
  .detail-price { font-size: 18px; font-weight: 700; color: var(--green); }

  .detail-tags { display: flex; flex-wrap: wrap; gap: 6px; }
  .tag {
    padding: 3px 8px; border-radius: var(--radius-pill);
    background: rgba(255,255,255,0.04); font-size: 11px;
    font-weight: 600; color: var(--text-secondary); text-transform: capitalize;
  }
  .tag.hunt { color: var(--red); background: var(--red-dim); }
  .tag.trick { color: var(--accent); background: var(--accent-dim); }
  .tag.k9 { color: var(--gold); background: var(--gold-dim); }

  .detail-stats { display: flex; flex-direction: column; gap: 4px; }
  .stat-row {
    display: flex; justify-content: space-between; font-size: 12px;
    padding: 4px 0; border-bottom: 1px solid rgba(255,255,255,0.03);
  }
  .stat-row span:first-child { color: var(--text-muted); }
  .stat-row span:last-child { color: var(--text-primary); font-weight: 600; }

  .locked-notice {
    padding: 10px; background: var(--red-dim); border: 1px solid var(--red-border);
    border-radius: var(--radius-sm); font-size: 12px; color: var(--red); text-align: center;
  }

  .name-input {
    width: 100%; padding: 8px 10px;
    background: var(--bg-input); border: 1px solid var(--border);
    border-radius: var(--radius-sm); color: var(--text-primary);
    font-size: 13px; font-family: var(--font); outline: none;
  }
  .name-input:focus { border-color: var(--accent-border); }
  .name-input::placeholder { color: var(--text-muted); }

  .buy-buttons { display: flex; gap: 8px; }
  .buy-btn {
    flex: 1; padding: 10px; border-radius: var(--radius-sm);
    font-size: 13px; font-weight: 700; font-family: var(--font);
    cursor: pointer; border: none; transition: all 0.15s;
  }
  .buy-btn.cash {
    background: linear-gradient(135deg, #264a26 0%, #367836 100%);
    color: #c8e6c9;
  }
  .buy-btn.cash:hover { filter: brightness(1.15); }
  .buy-btn.bank {
    background: linear-gradient(135deg, #263a5e 0%, #35609e 100%);
    color: #c8d6e6;
  }
  .buy-btn.bank:hover { filter: brightness(1.15); }

  .balance {
    font-size: 11px; color: var(--text-muted); text-align: center;
  }
</style>
