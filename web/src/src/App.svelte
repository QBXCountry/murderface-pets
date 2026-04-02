<script>
  import { onNuiMessage, fetchNui } from './lib/nui.js';
  import { createPetStore } from './lib/stores.svelte.js';
  import CompanionMenu from './screens/CompanionMenu.svelte';
  import PetShop from './screens/PetShop.svelte';

  const store = createPetStore();

  // ---- NUI Message Listeners ----
  onNuiMessage('openShop', (data) => store.openShop(data));
  onNuiMessage('openCompanion', (data) => store.openCompanion(data));
  onNuiMessage('updatePetStats', (data) => store.updatePetStats(data));
  onNuiMessage('close', () => { store.close(); });

  // ---- Keyboard ----
  function handleKeydown(e) {
    if (e.key === 'Escape' && store.visible) {
      e.preventDefault();
      store.close();
    }
  }

  // ---- Dev mode: auto-open for browser testing ----
  store.initDev();
</script>

<svelte:window onkeydown={handleKeydown} />

{#if store.visible}
  <div class="nui-root" class:fade-in={store.visible}>
    {#if store.screen === 'companion'}
      <CompanionMenu {store} />
    {:else if store.screen === 'shop'}
      <PetShop {store} />
    {/if}
  </div>
{/if}

<style>
  .nui-root {
    position: fixed;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    pointer-events: none;
    z-index: 9999;
  }

  .nui-root > :global(*) {
    pointer-events: auto;
  }

  .fade-in {
    animation: fadeIn 0.15s ease-out;
  }

  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
</style>
