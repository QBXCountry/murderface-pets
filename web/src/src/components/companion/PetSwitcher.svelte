<script>
  let { pets = [], currentHash = '', onswitch = () => {} } = $props();
</script>

<div class="switcher">
  <div class="switcher-label">Switch Pet</div>
  <div class="switcher-list">
    {#each pets as pet (pet.hash)}
      <button
        class="pet-tab"
        class:active={pet.hash === currentHash}
        onclick={() => onswitch(pet.hash)}
      >
        <span class="pet-tab-name">{pet.name}</span>
        <span class="pet-tab-level">Lv.{pet.level}</span>
      </button>
    {/each}
  </div>
</div>

<style>
  .switcher {
    border-top: 1px solid var(--border);
    padding: 10px 14px;
  }
  .switcher-label {
    font-size: 10px;
    font-weight: 700;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
  }
  .switcher-list {
    display: flex;
    gap: 6px;
  }
  .pet-tab {
    flex: 1;
    padding: 8px 10px;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--text-secondary);
    font-family: var(--font);
    cursor: pointer;
    text-align: center;
    transition: all 0.15s;
  }
  .pet-tab:hover { border-color: var(--border-hover); color: var(--text-primary); }
  .pet-tab.active {
    background: var(--accent-dim);
    border-color: var(--accent-border);
    color: var(--accent);
  }
  .pet-tab-name { display: block; font-size: 12px; font-weight: 600; }
  .pet-tab-level { display: block; font-size: 10px; color: var(--text-muted); }
  .pet-tab.active .pet-tab-level { color: var(--accent); }
</style>
