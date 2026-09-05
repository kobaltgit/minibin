<script lang="ts">
  import { onMount } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
  import { listen, type UnlistenFn } from '@tauri-apps/api/event';
  import type { RecycleBinStats, RecycleBinItem, AppSettings } from '$lib/types';
  import { translations } from '$lib/i18n';

  let stats = $state<RecycleBinStats>({
    total_size_bytes: 0,
    item_count: 0,
    is_empty: true,
    formatted_size: '0 B'
  });

  let items = $state<RecycleBinItem[]>([]);
  let settings = $state<AppSettings>({
    language: 'ru',
    theme: 'dark',
    icon_theme: 'fluent',
    click_action_lmb: 'toggle_flyout',
    click_action_mmb: 'empty_bin',
    click_action_double: 'open_bin',
    confirm_empty: false,
    play_sound: true,
    autorun: true,
    alert_threshold_gb: 10,
    custom_empty_icon: null,
    custom_full_icon: null
  });

  let activeTab = $state<'overview' | 'settings'>('overview');
  let searchQuery = $state('');
  let isLoading = $state(false);
  let isActionPending = $state(false);
  let showConfirmEmpty = $state(false);

  let t = $derived(translations[settings.language] || translations.ru);

  let filteredItems = $derived(
    items.filter(item =>
      item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.original_path.toLowerCase().includes(searchQuery.toLowerCase())
    )
  );

  let storagePercentage = $derived.by(() => {
    const limitBytes = (settings.alert_threshold_gb > 0 ? settings.alert_threshold_gb : 10) * 1024 * 1024 * 1024;
    const ratio = Math.min(100, Math.max(0, (stats.total_size_bytes / limitBytes) * 100));
    return stats.is_empty ? 0 : Math.max(5, Math.round(ratio));
  });

  let isOverThreshold = $derived.by(() => {
    if (settings.alert_threshold_gb <= 0) return false;
    const limitBytes = settings.alert_threshold_gb * 1024 * 1024 * 1024;
    return stats.total_size_bytes >= limitBytes;
  });

  async function loadData() {
    try {
      isLoading = true;
      const [resStats, resSettings] = await Promise.all([
        invoke<RecycleBinStats>('get_bin_stats'),
        invoke<AppSettings>('get_settings')
      ]);
      stats = resStats;
      settings = resSettings;
      applyTheme(resSettings.theme);

      // Async fetch of deleted items
      invoke<RecycleBinItem[]>('get_bin_items')
        .then(resItems => {
          items = resItems;
        })
        .catch(err => {
          console.error('Failed to get items:', err);
        })
        .finally(() => {
          isLoading = false;
        });
    } catch (e) {
      console.error('Failed to load initial data:', e);
      isLoading = false;
    }
  }

  function applyTheme(theme: string) {
    const root = document.documentElement;
    if (theme === 'system') {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      root.setAttribute('data-theme', prefersDark ? 'dark' : 'light');
    } else {
      root.setAttribute('data-theme', theme);
    }
  }

  async function handleEmptyBin() {
    if (stats.is_empty) return;

    if (settings.confirm_empty && !showConfirmEmpty) {
      showConfirmEmpty = true;
      return;
    }

    try {
      isActionPending = true;
      showConfirmEmpty = false;
      await invoke('empty_bin');
      await loadData();
    } catch (e) {
      console.error('Empty bin error:', e);
    } finally {
      isActionPending = false;
    }
  }

  async function handleRestore(id: string) {
    try {
      isActionPending = true;
      await invoke('restore_item', { itemId: id });
      await loadData();
    } catch (e) {
      console.error('Restore error:', e);
    } finally {
      isActionPending = false;
    }
  }

  async function handleDeletePermanently(id: string) {
    try {
      isActionPending = true;
      await invoke('delete_item', { itemId: id });
      await loadData();
    } catch (e) {
      console.error('Delete error:', e);
    } finally {
      isActionPending = false;
    }
  }

  async function handleOpenBin() {
    try {
      await invoke('open_bin');
    } catch (e) {
      console.error('Open bin error:', e);
    }
  }

  async function handleOpenDesktopSettings() {
    try {
      await invoke('open_desktop_settings');
    } catch (e) {
      console.error('Desktop settings error:', e);
    }
  }

  async function updateSetting<K extends keyof AppSettings>(key: K, val: AppSettings[K]) {
    settings[key] = val;
    if (key === 'theme') {
      applyTheme(val as string);
    }
    try {
      await invoke('save_settings', { settings });
    } catch (e) {
      console.error('Save settings error:', e);
    }
  }

  async function handlePickCustomIcon(target: 'empty' | 'full') {
    try {
      const res = await invoke<string | null>('select_custom_icon', { target });
      if (res) {
        if (target === 'empty') {
          settings.custom_empty_icon = res;
        } else {
          settings.custom_full_icon = res;
        }
        settings.icon_theme = 'custom';
      }
    } catch (e) {
      console.error('Pick custom icon error:', e);
    }
  }

  async function handleResetCustomIcons() {
    try {
      await invoke('reset_custom_icons');
      settings.custom_empty_icon = null;
      settings.custom_full_icon = null;
      settings.icon_theme = 'fluent';
    } catch (e) {
      console.error('Reset custom icons error:', e);
    }
  }

  async function handleClose() {
    try {
      await invoke('close_flyout');
    } catch (e) {
      console.error('Close flyout error:', e);
    }
  }

  onMount(() => {
    loadData();

    let unlisten: UnlistenFn | undefined;
    listen<string>('switch-tab', async (event) => {
      if (event.payload === 'settings' || event.payload === 'overview') {
        activeTab = event.payload;
        showConfirmEmpty = false;
        await loadData();
      }
    }).then((u) => {
      unlisten = u;
    });

    // Polling interval when flyout is open
    const interval = setInterval(() => {
      invoke<RecycleBinStats>('get_bin_stats').then(res => {
        if (res.item_count !== stats.item_count || res.total_size_bytes !== stats.total_size_bytes) {
          stats = res;
          invoke<RecycleBinItem[]>('get_bin_items').then(i => { items = i; });
        }
      });
    }, 3000);

    return () => {
      clearInterval(interval);
      if (unlisten) unlisten();
    };
  });
</script>

<div class="flyout-container">
  <!-- Header Bar -->
  <header class="flyout-header">
    <div class="brand">
      <div class="brand-icon {stats.is_empty ? 'empty' : 'full'}">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="3 6 5 6 21 6"></polyline>
          <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
          {#if !stats.is_empty}
            <line x1="10" y1="11" x2="10" y2="17"></line>
            <line x1="14" y1="11" x2="14" y2="17"></line>
          {/if}
        </svg>
      </div>
      <div class="brand-text">
        <span class="brand-name">{t.app_title}</span>
        <span class="brand-status">
          {stats.is_empty ? t.status_clean : `${stats.item_count} ${t.status_has_items}`}
        </span>
      </div>
    </div>

    <div class="header-actions">
      <!-- Tab Switcher -->
      <button
        class="icon-btn {activeTab === 'settings' ? 'active' : ''}"
        onclick={() => { activeTab = activeTab === 'overview' ? 'settings' : 'overview'; showConfirmEmpty = false; }}
        title={t.tab_settings}
        aria-label={t.tab_settings}
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="3"></circle>
          <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
        </svg>
      </button>

      <!-- Close Button -->
      <button class="icon-btn close-btn" onclick={handleClose} title={t.close} aria-label={t.close}>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
      </button>
    </div>
  </header>

  <!-- Content Switcher -->
  {#if activeTab === 'overview'}
    <main class="tab-content overview-tab">
      <!-- Storage Hero Card -->
      <div class="storage-card {isOverThreshold ? 'over-threshold' : ''}">
        <div class="storage-meta">
          <div class="size-display">
            <span class="size-val">{stats.formatted_size}</span>
            <span class="size-count">
              {stats.item_count} {settings.language === 'ru' ? 'объектов' : 'items'}
            </span>
          </div>
          <button
            class="action-pill refresh-pill"
            onclick={loadData}
            disabled={isLoading}
            title={t.refresh}
          >
            <svg class={isLoading ? 'spinning' : ''} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="23 4 23 10 17 10"></polyline>
              <polyline points="1 20 1 14 7 14"></polyline>
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
            </svg>
          </button>
        </div>

        <!-- Progress Bar -->
        <div class="progress-bar-bg">
          <div
            class="progress-bar-fill {isOverThreshold ? 'alert' : ''}"
            style="width: {storagePercentage}%;"
          ></div>
        </div>

        <!-- Quick Action Buttons -->
        <div class="card-buttons">
          {#if showConfirmEmpty}
            <div class="confirm-box">
              <span class="confirm-text">{t.confirm_empty_prompt}</span>
              <div class="confirm-actions">
                <button
                  class="btn btn-danger-solid btn-sm"
                  onclick={handleEmptyBin}
                  disabled={isActionPending}
                >
                  {t.yes_empty}
                </button>
                <button
                  class="btn btn-ghost btn-sm"
                  onclick={() => { showConfirmEmpty = false; }}
                >
                  {t.cancel}
                </button>
              </div>
            </div>
          {:else}
            <button
              class="btn btn-danger"
              onclick={handleEmptyBin}
              disabled={stats.is_empty || isActionPending}
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="3 6 5 6 21 6"></polyline>
                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
              </svg>
              <span>{t.empty_bin}</span>
            </button>

            <button class="btn btn-secondary" onclick={handleOpenBin}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
              </svg>
              <span>{t.open_explorer}</span>
            </button>
          {/if}
        </div>
      </div>

      <!-- Search and Filter -->
      {#if items.length > 0}
        <div class="search-box">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"></circle>
            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
          <input
            type="text"
            placeholder={t.search_placeholder}
            bind:value={searchQuery}
          />
          {#if searchQuery}
            <button class="clear-search" onclick={() => { searchQuery = ''; }}>×</button>
          {/if}
        </div>
      {/if}

      <!-- Deleted Items List -->
      <div class="items-section">
        {#if items.length === 0}
          <div class="empty-state">
            <div class="empty-illustration">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                <polyline points="22 4 12 14.01 9 11.01"></polyline>
              </svg>
            </div>
            <h4>{t.status_clean}</h4>
            <p>{t.empty_bin_description}</p>
          </div>
        {:else if filteredItems.length === 0}
          <div class="empty-state">
            <p>{t.no_items_found}</p>
          </div>
        {:else}
          <div class="item-list">
            {#each filteredItems as item (item.id)}
              <div class="item-card">
                <div class="item-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
                    <polyline points="13 2 13 9 20 9"></polyline>
                  </svg>
                </div>
                <div class="item-info">
                  <div class="item-title" title={item.name}>{item.name}</div>
                  <div class="item-sub">
                    <span class="item-size">{item.formatted_size}</span>
                    {#if item.date_deleted}
                      <span class="item-dot">•</span>
                      <span class="item-date">{item.date_deleted}</span>
                    {/if}
                  </div>
                </div>
                <div class="item-actions">
                  <button
                    class="btn-row-action restore"
                    onclick={() => handleRestore(item.id)}
                    title={t.restore_item}
                    disabled={isActionPending}
                  >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                      <polyline points="1 4 1 10 7 10"></polyline>
                      <path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"></path>
                    </svg>
                  </button>
                  <button
                    class="btn-row-action delete"
                    onclick={() => handleDeletePermanently(item.id)}
                    title={t.delete_permanently}
                    disabled={isActionPending}
                  >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                      <line x1="18" y1="6" x2="6" y2="18"></line>
                      <line x1="6" y1="6" x2="18" y2="18"></line>
                    </svg>
                  </button>
                </div>
              </div>
            {/each}
          </div>
        {/if}
      </div>
    </main>
  {:else}
    <!-- Settings Tab -->
    <main class="tab-content settings-tab">
      <div class="settings-scroll">
        <!-- Appearance Group -->
        <div class="settings-group">
          <div class="group-title">{t.general_section}</div>

          <!-- Language -->
          <div class="setting-row">
            <div class="setting-label">
              <span>{t.language}</span>
            </div>
            <select
              value={settings.language}
              onchange={(e) => updateSetting('language', (e.target as HTMLSelectElement).value as 'ru' | 'en')}
            >
              <option value="ru">Русский (RU)</option>
              <option value="en">English (EN)</option>
            </select>
          </div>

          <!-- Theme -->
          <div class="setting-row">
            <div class="setting-label">
              <span>{t.theme}</span>
            </div>
            <select
              value={settings.theme}
              onchange={(e) => updateSetting('theme', (e.target as HTMLSelectElement).value as 'dark' | 'light' | 'system')}
            >
              <option value="dark">{t.theme_dark}</option>
              <option value="light">{t.theme_light}</option>
              <option value="system">{t.theme_system}</option>
            </select>
          </div>

          <!-- Icon Theme -->
          <div class="setting-row">
            <div class="setting-label">
              <span>{t.icon_pack}</span>
            </div>
            <select
              value={settings.icon_theme}
              onchange={(e) => updateSetting('icon_theme', (e.target as HTMLSelectElement).value as any)}
            >
              <option value="fluent">{t.icon_fluent}</option>
              <option value="retro">{t.icon_retro}</option>
              <option value="minimal">{t.icon_minimal}</option>
              <option value="original">{t.icon_original}</option>
              <option value="custom">{t.icon_custom}</option>
            </select>
          </div>

          {#if settings.icon_theme === 'custom'}
            <div class="custom-icons-panel">
              <div class="setting-row custom-icon-row">
                <div class="setting-label custom-label-col">
                  <span>{t.custom_empty_label}</span>
                  <span class="custom-status">{settings.custom_empty_icon ? '✓ Задан' : 'Не выбран'}</span>
                </div>
                <button class="btn btn-secondary btn-sm" onclick={() => handlePickCustomIcon('empty')}>
                  {t.choose_file}
                </button>
              </div>

              <div class="setting-row custom-icon-row">
                <div class="setting-label custom-label-col">
                  <span>{t.custom_full_label}</span>
                  <span class="custom-status">{settings.custom_full_icon ? '✓ Задан' : 'Не выбран'}</span>
                </div>
                <button class="btn btn-secondary btn-sm" onclick={() => handlePickCustomIcon('full')}>
                  {t.choose_file}
                </button>
              </div>

              {#if settings.custom_empty_icon || settings.custom_full_icon}
                <div class="custom-reset-row">
                  <button class="btn btn-sm btn-danger" onclick={handleResetCustomIcons}>
                    {t.reset_custom_icons}
                  </button>
                </div>
              {/if}
            </div>
          {/if}
        </div>

        <!-- Mouse Actions Group -->
        <div class="settings-group">
          <div class="group-title">{t.mouse_actions_section}</div>

          <!-- LMB -->
          <div class="setting-row">
            <div class="setting-label">
              <span>{t.lmb_action}</span>
            </div>
            <select
              value={settings.click_action_lmb}
              onchange={(e) => updateSetting('click_action_lmb', (e.target as HTMLSelectElement).value)}
            >
              <option value="toggle_flyout">{t.action_flyout}</option>
              <option value="open_bin">{t.action_open_bin}</option>
            </select>
          </div>

          <!-- MMB -->
          <div class="setting-row">
            <div class="setting-label">
              <span>{t.mmb_action}</span>
            </div>
            <select
              value={settings.click_action_mmb}
              onchange={(e) => updateSetting('click_action_mmb', (e.target as HTMLSelectElement).value)}
            >
              <option value="empty_bin">{t.action_empty_bin}</option>
              <option value="none">{t.action_none}</option>
            </select>
          </div>

          <!-- Double Click -->
          <div class="setting-row">
            <div class="setting-label">
              <span>{t.double_click_action}</span>
            </div>
            <select
              value={settings.click_action_double}
              onchange={(e) => updateSetting('click_action_double', (e.target as HTMLSelectElement).value)}
            >
              <option value="open_bin">{t.action_open_bin}</option>
              <option value="empty_bin">{t.action_empty_bin}</option>
            </select>
          </div>
        </div>

        <!-- System & Behavior Group -->
        <div class="settings-group">
          <div class="group-title">{t.behavior_section}</div>

          <!-- Autorun -->
          <div class="setting-toggle-row">
            <div class="toggle-text">
              <span class="toggle-title">{t.autorun}</span>
              <span class="toggle-sub">{t.autorun_desc}</span>
            </div>
            <label class="switch">
              <input
                type="checkbox"
                checked={settings.autorun}
                onchange={(e) => updateSetting('autorun', (e.target as HTMLInputElement).checked)}
              />
              <span class="slider"></span>
            </label>
          </div>

          <!-- Play Sound -->
          <div class="setting-toggle-row">
            <div class="toggle-text">
              <span class="toggle-title">{t.play_sound}</span>
              <span class="toggle-sub">{t.play_sound_desc}</span>
            </div>
            <label class="switch">
              <input
                type="checkbox"
                checked={settings.play_sound}
                onchange={(e) => updateSetting('play_sound', (e.target as HTMLInputElement).checked)}
              />
              <span class="slider"></span>
            </label>
          </div>

          <!-- Confirm Empty -->
          <div class="setting-toggle-row">
            <div class="toggle-text">
              <span class="toggle-title">{t.confirm_empty}</span>
              <span class="toggle-sub">{t.confirm_empty_desc}</span>
            </div>
            <label class="switch">
              <input
                type="checkbox"
                checked={settings.confirm_empty}
                onchange={(e) => updateSetting('confirm_empty', (e.target as HTMLInputElement).checked)}
              />
              <span class="slider"></span>
            </label>
          </div>

          <!-- Alert Threshold -->
          <div class="setting-row">
            <div class="setting-label">
              <span>{t.alert_threshold}</span>
            </div>
            <select
              bind:value={settings.alert_threshold_gb}
              onchange={() => updateSetting('alert_threshold_gb', Number(settings.alert_threshold_gb))}
            >
              <option value={0}>{t.threshold_off}</option>
              <option value={5}>5 {t.threshold_gb}</option>
              <option value={10}>10 {t.threshold_gb}</option>
              <option value={20}>20 {t.threshold_gb}</option>
              <option value={50}>50 {t.threshold_gb}</option>
            </select>
          </div>

          <!-- Desktop Icons Link Button -->
          <div class="desktop-link-card">
            <div class="desktop-link-info">
              <span class="desktop-title">{t.hide_desktop_icon}</span>
              <span class="desktop-desc">{t.hide_desktop_icon_desc}</span>
            </div>
            <button class="btn btn-secondary btn-sm" onclick={handleOpenDesktopSettings}>
              {t.open_desk_cpl}
            </button>
          </div>
        </div>

        <div class="version-footer">
          {t.version}
        </div>
      </div>
    </main>
  {/if}
</div>

<style>
  .flyout-container {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    background: var(--bg-surface);
    backdrop-filter: blur(28px) saturate(180%);
    -webkit-backdrop-filter: blur(28px) saturate(180%);
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-window);
    box-shadow: var(--shadow-window);
    overflow: hidden;
    position: relative;
  }

  /* Header */
  .flyout-header {
    height: 52px;
    padding: 0 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid var(--border-subtle);
    background: rgba(0, 0, 0, 0.04);
    flex-shrink: 0;
  }

  .brand {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .brand-icon {
    width: 28px;
    height: 28px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    color: var(--accent-blue);
    transition: transform 0.2s ease;
  }

  .brand-icon.full {
    color: var(--accent-warning);
    border-color: rgba(245, 158, 11, 0.3);
  }

  .brand-icon svg {
    width: 16px;
    height: 16px;
  }

  .brand-text {
    display: flex;
    flex-direction: column;
  }

  .brand-name {
    font-size: 13px;
    font-weight: 700;
    letter-spacing: -0.2px;
    color: var(--text-primary);
  }

  .brand-status {
    font-size: 11px;
    color: var(--text-secondary);
    line-height: 1.1;
  }

  .header-actions {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .icon-btn {
    width: 30px;
    height: 30px;
    border-radius: 7px;
    background: transparent;
    border: none;
    color: var(--text-secondary);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.15s ease;
  }

  .icon-btn svg {
    width: 16px;
    height: 16px;
  }

  .icon-btn:hover {
    background: var(--bg-card);
    color: var(--text-primary);
  }

  .icon-btn.active {
    background: var(--bg-card-hover);
    color: var(--accent-blue);
  }

  .close-btn:hover {
    background: var(--accent-danger-bg);
    color: var(--accent-danger);
  }

  /* Main Tab Content */
  .tab-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .overview-tab {
    padding: 14px 14px 10px 14px;
    gap: 12px;
  }

  /* Storage Hero Card */
  .storage-card {
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-card);
    padding: 12px 14px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    transition: all 0.2s ease;
  }

  .storage-card.over-threshold {
    border-color: rgba(244, 63, 94, 0.4);
    box-shadow: 0 0 16px rgba(244, 63, 94, 0.12);
  }

  .storage-meta {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
  }

  .size-display {
    display: flex;
    align-items: baseline;
    gap: 8px;
  }

  .size-val {
    font-size: 22px;
    font-weight: 800;
    letter-spacing: -0.5px;
    color: var(--text-primary);
  }

  .size-count {
    font-size: 12px;
    color: var(--text-secondary);
    font-weight: 500;
  }

  .action-pill {
    background: transparent;
    border: 1px solid var(--border-subtle);
    width: 26px;
    height: 26px;
    border-radius: 50%;
    color: var(--text-secondary);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.15s;
  }

  .action-pill:hover:not(:disabled) {
    background: var(--bg-card-hover);
    color: var(--text-primary);
  }

  .action-pill svg {
    width: 13px;
    height: 13px;
  }

  .spinning {
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }

  .progress-bar-bg {
    width: 100%;
    height: 6px;
    background: rgba(148, 163, 184, 0.15);
    border-radius: 999px;
    overflow: hidden;
  }

  .progress-bar-fill {
    height: 100%;
    background: linear-gradient(90deg, var(--accent-blue), #38bdf8);
    border-radius: 999px;
    transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .progress-bar-fill.alert {
    background: linear-gradient(90deg, #f59e0b, var(--accent-danger));
  }

  .card-buttons {
    display: flex;
    gap: 8px;
    margin-top: 2px;
  }

  .btn {
    flex: 1;
    height: 32px;
    border-radius: 7px;
    font-size: 12px;
    font-weight: 600;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    cursor: pointer;
    border: none;
    transition: all 0.15s ease;
  }

  .btn svg {
    width: 14px;
    height: 14px;
  }

  .btn-sm {
    height: 28px;
    font-size: 11px;
    padding: 0 10px;
  }

  .btn-danger {
    background: var(--accent-danger-bg);
    color: var(--accent-danger);
    border: 1px solid rgba(244, 63, 94, 0.25);
  }

  .btn-danger:hover:not(:disabled) {
    background: var(--accent-danger);
    color: white;
  }

  .btn-danger-solid {
    background: var(--accent-danger);
    color: white;
  }

  .btn-danger-solid:hover:not(:disabled) {
    background: var(--accent-danger-hover);
  }

  .btn-secondary {
    background: rgba(255, 255, 255, 0.06);
    color: var(--text-primary);
    border: 1px solid var(--border-subtle);
  }

  .btn-secondary:hover:not(:disabled) {
    background: var(--bg-card-hover);
  }

  .btn-ghost {
    background: transparent;
    color: var(--text-secondary);
    border: 1px solid var(--border-subtle);
  }

  .btn-ghost:hover {
    background: var(--bg-card);
    color: var(--text-primary);
  }

  .btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .confirm-box {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: 6px;
    background: rgba(244, 63, 94, 0.08);
    border: 1px solid rgba(244, 63, 94, 0.3);
    border-radius: 7px;
    padding: 6px 10px;
  }

  .confirm-text {
    font-size: 11px;
    font-weight: 600;
    color: var(--accent-danger);
    text-align: center;
  }

  .confirm-actions {
    display: flex;
    gap: 6px;
  }

  /* Search */
  .search-box {
    position: relative;
    display: flex;
    align-items: center;
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: 8px;
    padding: 0 10px;
    height: 32px;
    flex-shrink: 0;
  }

  .search-box svg {
    width: 14px;
    height: 14px;
    color: var(--text-muted);
    margin-right: 6px;
  }

  .search-box input {
    flex: 1;
    background: transparent;
    border: none;
    outline: none;
    color: var(--text-primary);
    font-size: 12px;
  }

  .search-box input::placeholder {
    color: var(--text-muted);
  }

  .clear-search {
    background: transparent;
    border: none;
    color: var(--text-muted);
    cursor: pointer;
    font-size: 16px;
    padding: 0 4px;
  }

  /* Items Section */
  .items-section {
    flex: 1;
    overflow-y: auto;
    padding-right: 2px;
    display: flex;
    flex-direction: column;
  }

  .item-list {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .item-card {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 10px;
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: 8px;
    transition: all 0.15s ease;
  }

  .item-card:hover {
    background: var(--bg-card-hover);
    border-color: rgba(255, 255, 255, 0.15);
  }

  .item-icon {
    width: 28px;
    height: 28px;
    border-radius: 6px;
    background: rgba(56, 189, 248, 0.12);
    color: var(--accent-blue);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .item-icon svg {
    width: 15px;
    height: 15px;
  }

  .item-info {
    flex: 1;
    min-width: 0;
  }

  .item-title {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-primary);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .item-sub {
    font-size: 10px;
    color: var(--text-muted);
    display: flex;
    align-items: center;
    gap: 4px;
    margin-top: 1px;
  }

  .item-actions {
    display: flex;
    align-items: center;
    gap: 4px;
    opacity: 0.8;
  }

  .item-card:hover .item-actions {
    opacity: 1;
  }

  .btn-row-action {
    width: 26px;
    height: 26px;
    border-radius: 6px;
    background: transparent;
    border: 1px solid var(--border-subtle);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.15s;
  }

  .btn-row-action svg {
    width: 13px;
    height: 13px;
  }

  .btn-row-action.restore {
    color: var(--accent-success);
  }

  .btn-row-action.restore:hover:not(:disabled) {
    background: rgba(16, 185, 129, 0.15);
    border-color: var(--accent-success);
  }

  .btn-row-action.delete {
    color: var(--accent-danger);
  }

  .btn-row-action.delete:hover:not(:disabled) {
    background: var(--accent-danger-bg);
    border-color: var(--accent-danger);
  }

  /* Empty State */
  .empty-state {
    margin: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    padding: 24px 16px;
    color: var(--text-secondary);
  }

  .empty-illustration {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    background: rgba(16, 185, 129, 0.12);
    color: var(--accent-success);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 12px;
  }

  .empty-illustration svg {
    width: 28px;
    height: 28px;
  }

  .empty-state h4 {
    margin: 0 0 4px 0;
    font-size: 14px;
    font-weight: 700;
    color: var(--text-primary);
  }

  .empty-state p {
    margin: 0;
    font-size: 11px;
    color: var(--text-muted);
    max-width: 200px;
    line-height: 1.4;
  }

  /* Settings Tab */
  .settings-scroll {
    flex: 1;
    overflow-y: auto;
    padding: 14px;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .settings-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .group-title {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--accent-blue);
    margin-bottom: 2px;
  }

  .setting-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: 8px;
    padding: 8px 12px;
    gap: 8px;
  }

  .setting-label {
    font-size: 12px;
    font-weight: 500;
    color: var(--text-primary);
  }

  .setting-row select {
    background: var(--bg-card-hover);
    border: 1px solid var(--border-subtle);
    border-radius: 6px;
    color: var(--text-primary);
    font-size: 11px;
    font-weight: 500;
    padding: 4px 8px;
    outline: none;
    cursor: pointer;
  }

  .setting-row select option {
    background: #1f242c;
    color: #f1f5f9;
  }

  .setting-toggle-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: 8px;
    padding: 8px 12px;
    gap: 12px;
  }

  .toggle-text {
    display: flex;
    flex-direction: column;
  }

  .toggle-title {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-primary);
  }

  .toggle-sub {
    font-size: 10px;
    color: var(--text-muted);
    line-height: 1.2;
    margin-top: 1px;
  }

  /* Switch */
  .switch {
    position: relative;
    display: inline-block;
    width: 36px;
    height: 20px;
    flex-shrink: 0;
  }

  .switch input {
    opacity: 0;
    width: 0;
    height: 0;
  }

  .slider {
    position: absolute;
    cursor: pointer;
    top: 0; left: 0; right: 0; bottom: 0;
    background-color: rgba(148, 163, 184, 0.25);
    transition: 0.2s;
    border-radius: 999px;
  }

  .slider:before {
    position: absolute;
    content: "";
    height: 14px;
    width: 14px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: 0.2s;
    border-radius: 50%;
  }

  input:checked + .slider {
    background-color: var(--accent-blue);
  }

  input:checked + .slider:before {
    transform: translateX(16px);
  }

  /* Desktop Link Card */
  .desktop-link-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: rgba(56, 189, 248, 0.08);
    border: 1px solid rgba(56, 189, 248, 0.2);
    border-radius: 8px;
    padding: 10px 12px;
    margin-top: 4px;
    gap: 10px;
  }

  .desktop-link-info {
    display: flex;
    flex-direction: column;
  }

  .desktop-title {
    font-size: 11.5px;
    font-weight: 600;
    color: var(--text-primary);
  }

  .desktop-desc {
    font-size: 10px;
    color: var(--text-muted);
    line-height: 1.2;
    margin-top: 1px;
  }

  .custom-icons-panel {
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding: 8px 10px;
    background: rgba(15, 23, 42, 0.25);
    border-radius: 8px;
    border: 1px dashed var(--border-subtle);
    margin-top: 4px;
  }

  .custom-icon-row {
    background: transparent;
    border: none;
    padding: 2px 0;
  }

  .custom-label-col {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .custom-status {
    font-size: 10px;
    color: var(--accent-blue);
    font-weight: 500;
  }

  .custom-reset-row {
    display: flex;
    justify-content: flex-end;
    margin-top: 4px;
    padding-top: 4px;
    border-top: 1px solid var(--border-subtle);
  }

  .version-footer {
    text-align: center;
    font-size: 10px;
    color: var(--text-muted);
    padding: 12px 0 6px 0;
  }
</style>
