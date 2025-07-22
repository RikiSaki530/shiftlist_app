
lib/
├── models/
│   ├── app_user.dart          // AppUser（ID／名前／isAdmin フラグ）
│   ├── schedule_entry.dart    // ScheduleEntry（studentName, recurrence, ownerId）
│   ├── slot_type.dart         // SlotType enum（A/B/C…）
│
└── views/
    ├── login_screen.dart           // ログイン／ユーザー切り替え ←phase2
    ├── calendar_screen.dart        // 月間カレンダー
    ├── date_detail_screen.dart     // 日付別シフト一覧
    ├── entry_form_screen.dart      // シフト登録・編集フォーム
    ├── pdf_output_screen.dart      // 月次 PDF 出力（年月ピッカー＋生成ボタン）
    ├── pdf_preview_screen.dart     // （オプション）PDF プレビュー　←phase2
    ├── user_management_screen.dart // 管理者用：バイト生一覧・権限切替　←phase2
    ├── slot_settings_screen.dart   // 管理者用：コマ（SlotType）時刻カスタマイズ ←phase2
    └── settings_screen.dart        // 全ユーザー共通：データ取込・エクスポート／アプリ情報 ←phase2