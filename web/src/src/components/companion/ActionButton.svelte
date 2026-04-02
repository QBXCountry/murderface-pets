<script>
  let { label = '', icon = 'paw', available = true, active = false, lockedLevel = null, onclick = () => {} } = $props();
</script>

<button
  class="action-btn"
  class:unavailable={!available}
  class:active
  disabled={!available}
  {onclick}
>
  <span class="action-label">{label}</span>
  {#if lockedLevel !== null}
    <span class="lock-badge">Lv.{lockedLevel}</span>
  {/if}
  {#if active}
    <span class="active-dot"></span>
  {/if}
</button>

<style>
  .action-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    padding: 12px 8px;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--text-primary);
    font-size: 12px;
    font-weight: 600;
    font-family: var(--font);
    cursor: pointer;
    transition: all 0.15s;
    position: relative;
    min-height: 52px;
  }

  .action-btn:hover:not(:disabled) {
    background: var(--bg-card-hover);
    border-color: var(--accent-border);
    color: var(--accent);
  }

  .action-btn.active {
    background: var(--accent-dim);
    border-color: var(--accent-border);
    color: var(--accent);
  }

  .action-btn.unavailable {
    opacity: 0.4;
    cursor: not-allowed;
  }

  .action-label {
    font-size: 12px;
    font-weight: 600;
  }

  .lock-badge {
    font-size: 9px;
    color: var(--text-muted);
    background: rgba(255, 255, 255, 0.04);
    padding: 1px 6px;
    border-radius: 8px;
  }

  .active-dot {
    position: absolute;
    top: 6px;
    right: 6px;
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--accent);
    box-shadow: 0 0 6px var(--accent);
  }
</style>
