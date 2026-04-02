<script>
  import { formatPrice, xpPercent } from '../lib/utils.js';
  import ProgressBar from '../components/shared/ProgressBar.svelte';
  import ActionButton from '../components/companion/ActionButton.svelte';
  import PetSwitcher from '../components/companion/PetSwitcher.svelte';

  let { store } = $props();
  let activeTab = $state('commands');
</script>

<div class="companion-panel">
  <!-- Header: Pet Info -->
  <div class="panel-header">
    <button class="close-btn" onclick={() => store.close()}>x</button>
    {#if store.pet}
      <div class="pet-name">{store.pet.name}</div>
      <div class="pet-subtitle">Lv.{store.pet.level} {store.pet.levelTitle}</div>

      <div class="bars">
        <ProgressBar label="XP" value={xpPercent(store.pet.xp, store.pet.xpNeeded)} color="var(--xp-color)" />
        <ProgressBar label="HP" value={Math.round((store.pet.health / store.pet.maxHealth) * 100)} color="var(--health-color)" />
        <ProgressBar label="Food" value={store.pet.food} color="var(--hunger-color)" />
      </div>
    {/if}
  </div>

  <!-- Tabs -->
  <div class="tabs">
    {#each ['commands', 'tricks', 'stats', 'settings'] as tab}
      <button
        class="tab" class:active={activeTab === tab}
        onclick={() => activeTab = tab}
      >{tab}</button>
    {/each}
  </div>

  <!-- Tab Content -->
  <div class="tab-content">
    {#if activeTab === 'commands'}
      <div class="action-grid">
        {#each store.actions as action}
          <ActionButton
            label={action.label}
            icon={action.icon}
            available={action.available}
            active={
              (action.type === 'Guard' && store.isGuarding) ||
              (action.type === 'Aggro' && store.isAggroed)
            }
            onclick={() => store.executeAction(action.type)}
          />
        {/each}
      </div>

    {:else if activeTab === 'tricks'}
      <div class="action-grid">
        {#each store.tricks as trick}
          <ActionButton
            label={trick.label}
            icon={trick.icon}
            available={!trick.locked}
            lockedLevel={trick.locked ? trick.requiredLevel : null}
            onclick={() => store.executeTrick(trick.name)}
          />
        {/each}
      </div>

    {:else if activeTab === 'stats'}
      <div class="stats-section">
        {#if store.pet}
          <div class="stat-row"><span>Species</span><span>{store.pet.species}</span></div>
          <div class="stat-row"><span>Size</span><span>{store.pet.size}</span></div>
          <div class="stat-row"><span>Health</span><span>{store.pet.health} / {store.pet.maxHealth}</span></div>
          <div class="stat-row"><span>XP</span><span>{store.pet.xp} / {store.pet.xpNeeded}</span></div>
          <div class="stat-row"><span>Can Hunt</span><span>{store.pet.canHunt ? 'Yes' : 'No'}</span></div>
          <div class="stat-row"><span>Can Trick</span><span>{store.pet.canTrick ? 'Yes' : 'No'}</span></div>
          {#if store.pet.specialization}
            <div class="stat-row"><span>Specialization</span><span class="accent">{store.pet.specialization}</span></div>
          {:else if store.canSpecialize}
            <div class="spec-section">
              <div class="spec-title">Choose Specialization</div>
              {#each Object.entries(store.specializations) as [key, spec]}
                <button class="spec-btn" onclick={() => store.specialize(key)}>
                  <strong>{spec.label}</strong>
                  <span>{spec.desc}</span>
                </button>
              {/each}
            </div>
          {/if}
        {/if}
      </div>

    {:else if activeTab === 'settings'}
      <div class="settings-section">
        <label class="setting">
          <span>Pet Name</span>
          <input
            type="text"
            value={store.pet?.name || ''}
            onchange={(e) => store.renamePet(e.target.value)}
            maxlength="20"
          />
        </label>

        <label class="setting">
          <span>Follow Distance</span>
          <input
            type="range" min="1" max="5" step="0.5"
            value={store.settings.followDistance}
            oninput={(e) => store.updateSetting('followDistance', parseFloat(e.target.value))}
          />
          <span class="setting-value">{store.settings.followDistance}m</span>
        </label>

        <label class="setting toggle">
          <span>Ambient AI</span>
          <input
            type="checkbox"
            checked={store.settings.ambientAI}
            onchange={() => store.updateSetting('ambientAI', !store.settings.ambientAI)}
          />
        </label>

        <label class="setting toggle">
          <span>Owner Reactions</span>
          <input
            type="checkbox"
            checked={store.settings.ownerReactions}
            onchange={() => store.updateSetting('ownerReactions', !store.settings.ownerReactions)}
          />
        </label>
      </div>
    {/if}
  </div>

  <!-- Multi-pet switcher -->
  {#if store.otherPets.length > 0}
    <PetSwitcher
      pets={store.otherPets}
      currentHash={store.pet?.hash}
      onswitch={(hash) => store.switchPet(hash)}
    />
  {/if}
</div>

<style>
  .companion-panel {
    width: 380px;
    max-height: 85vh;
    background: var(--bg-panel);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    margin-right: 24px;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .panel-header {
    padding: 20px 20px 14px;
    position: relative;
    border-bottom: 1px solid var(--border);
  }

  .close-btn {
    position: absolute;
    top: 12px;
    right: 14px;
    width: 28px;
    height: 28px;
    border-radius: 6px;
    background: transparent;
    border: 1px solid var(--border);
    color: var(--text-muted);
    font-size: 14px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.15s;
  }
  .close-btn:hover {
    color: var(--red);
    border-color: var(--red-border);
    background: var(--red-dim);
  }

  .pet-name {
    font-size: 20px;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 2px;
  }

  .pet-subtitle {
    font-size: 12px;
    color: var(--accent);
    font-weight: 600;
    margin-bottom: 12px;
  }

  .bars {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  /* Tabs */
  .tabs {
    display: flex;
    border-bottom: 1px solid var(--border);
    padding: 0 12px;
  }

  .tab {
    flex: 1;
    padding: 10px 8px;
    background: transparent;
    border: none;
    border-bottom: 2px solid transparent;
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 600;
    font-family: var(--font);
    cursor: pointer;
    text-transform: capitalize;
    transition: all 0.15s;
  }
  .tab:hover { color: var(--text-secondary); }
  .tab.active {
    color: var(--accent);
    border-bottom-color: var(--accent);
  }

  /* Tab content */
  .tab-content {
    flex: 1;
    overflow-y: auto;
    padding: 14px;
  }

  /* Action grid */
  .action-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
  }

  /* Stats */
  .stats-section {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .stat-row {
    display: flex;
    justify-content: space-between;
    padding: 8px 12px;
    background: var(--bg-card);
    border-radius: var(--radius-sm);
    font-size: 13px;
  }
  .stat-row span:first-child { color: var(--text-secondary); }
  .stat-row span:last-child { color: var(--text-primary); font-weight: 600; }
  .accent { color: var(--accent) !important; }

  /* Specialization */
  .spec-section {
    margin-top: 12px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .spec-title {
    font-size: 13px;
    font-weight: 700;
    color: var(--accent);
    margin-bottom: 4px;
  }
  .spec-btn {
    padding: 10px 14px;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    cursor: pointer;
    text-align: left;
    color: var(--text-primary);
    font-family: var(--font);
    transition: all 0.15s;
  }
  .spec-btn:hover {
    border-color: var(--accent-border);
    background: var(--accent-glow);
  }
  .spec-btn strong { display: block; font-size: 13px; margin-bottom: 2px; }
  .spec-btn span { font-size: 11px; color: var(--text-secondary); }

  /* Settings */
  .settings-section {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  .setting {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    font-size: 13px;
    color: var(--text-secondary);
  }
  .setting input[type="text"] {
    width: 140px;
    padding: 6px 10px;
    background: var(--bg-input);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--text-primary);
    font-size: 13px;
    font-family: var(--font);
    outline: none;
  }
  .setting input[type="text"]:focus { border-color: var(--accent-border); }
  .setting input[type="range"] { flex: 1; accent-color: var(--accent); }
  .setting-value { width: 30px; text-align: right; color: var(--accent); font-weight: 600; font-size: 12px; }
  .setting.toggle { cursor: pointer; }
  .setting input[type="checkbox"] { accent-color: var(--accent); width: 16px; height: 16px; }
</style>
