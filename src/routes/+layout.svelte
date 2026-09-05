<script lang="ts">
  import type { Snippet } from 'svelte';

  let { children }: { children: Snippet } = $props();
</script>

<svelte:head>
  <title>MiniBin</title>
</svelte:head>

<div class="app-shell">
  {@render children()}
</div>

<style>
  :global(:root) {
    --bg-surface: rgba(22, 27, 34, 0.78);
    --bg-card: rgba(33, 38, 45, 0.72);
    --bg-card-hover: rgba(48, 54, 61, 0.85);
    --border-subtle: rgba(240, 246, 252, 0.1);
    --border-accent: rgba(56, 189, 248, 0.4);
    --text-primary: #f0f6fc;
    --text-secondary: #8b949e;
    --text-muted: #6e7681;
    --accent-blue: #38bdf8;
    --accent-blue-hover: #0ea5e9;
    --accent-danger: #f43f5e;
    --accent-danger-hover: #e11d48;
    --accent-danger-bg: rgba(244, 63, 94, 0.15);
    --accent-success: #10b981;
    --accent-warning: #f59e0b;
    --shadow-window: 0 16px 40px rgba(0, 0, 0, 0.5), 0 0 0 1px rgba(255, 255, 255, 0.1);
    --radius-window: 14px;
    --radius-card: 10px;
    --radius-pill: 999px;
  }

  :global([data-theme="light"]) {
    --bg-surface: rgba(255, 255, 255, 0.86);
    --bg-card: rgba(243, 244, 246, 0.82);
    --bg-card-hover: rgba(229, 231, 235, 0.95);
    --border-subtle: rgba(0, 0, 0, 0.08);
    --border-accent: rgba(14, 165, 233, 0.4);
    --text-primary: #0f172a;
    --text-secondary: #475569;
    --text-muted: #64748b;
    --accent-blue: #0284c7;
    --accent-blue-hover: #0369a1;
    --accent-danger: #e11d48;
    --accent-danger-hover: #be123c;
    --accent-danger-bg: rgba(225, 29, 72, 0.1);
    --accent-success: #059669;
    --accent-warning: #d97706;
    --shadow-window: 0 16px 40px rgba(0, 0, 0, 0.2), 0 0 0 1px rgba(0, 0, 0, 0.08);
  }

  .app-shell {
    width: 380px;
    height: 520px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    background: transparent;
    user-select: none;
    -webkit-user-select: none;
  }
</style>
