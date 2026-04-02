<script>
  let { label = '', value = 0, color = 'var(--accent)' } = $props();
</script>

<div class="progress-bar">
  <div class="progress-label">
    <span>{label}</span>
    <span class="progress-value" style="color: {color}">{Math.round(value)}%</span>
  </div>
  <div class="progress-track">
    <div class="progress-fill" style="width: {Math.min(100, Math.max(0, value))}%; background: {color}"></div>
  </div>
</div>

<style>
  .progress-bar { width: 100%; }
  .progress-label {
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 3px;
  }
  .progress-label span { font-size: 11px; color: var(--text-muted); font-weight: 600; }
  .progress-value { font-size: 11px; font-weight: 700; }
  .progress-track {
    width: 100%; height: 6px; border-radius: 3px;
    background: rgba(255, 255, 255, 0.06); overflow: hidden;
  }
  .progress-fill {
    height: 100%; border-radius: 3px;
    transition: width 0.4s ease-out;
    box-shadow: 0 0 6px rgba(0, 0, 0, 0.2);
  }
</style>
