export interface RecycleBinStats {
  total_size_bytes: number;
  item_count: number;
  is_empty: boolean;
  formatted_size: string;
}

export interface RecycleBinItem {
  id: string;
  name: string;
  original_path: string;
  date_deleted: string;
  size: number;
  formatted_size: string;
}

export interface AppSettings {
  language: 'ru' | 'en';
  theme: 'dark' | 'light' | 'system';
  icon_theme: 'fluent' | 'retro' | 'minimal' | 'original' | 'custom';
  click_action_lmb: string;
  click_action_mmb: string;
  click_action_double: string;
  confirm_empty: boolean;
  play_sound: boolean;
  autorun: boolean;
  alert_threshold_gb: number;
  custom_empty_icon?: string | null;
  custom_full_icon?: string | null;
}
