# 模組包安裝與更新指南

*（English version: [docs/pack-install-guide.md](pack-install-guide.md)）*

本指南說明如何下載、安裝、加入與更新伺服器的 `.mrpack` 模組包。關於記憶體建議、按鍵對照與遊戲內起步教學，請參閱 [遊玩指南](play-guide.zh-TW.md)。

## 事前準備

- 一個正版 **Minecraft: Java Edition** 帳號（並請伺服器管理員加入白名單）。
- 安裝 **Modrinth App** 或 **Prism Launcher** 任一款啟動器。
- 取得管理員提供的固定 `.mrpack` 下載連結。
- 確認你的電腦符合 [遊玩指南 — 電腦需求](play-guide.zh-TW.md#電腦需求)。

## 1. 下載模組包

開啟管理員提供的固定下載連結（檔名結尾為 `/dist/mmc3.mrpack`），將 `.mrpack` 檔案存到電腦上。

## 2. 安裝模組包

### 方式 A：Modrinth App

1. 開啟 **Modrinth App** 並登入你的 Microsoft / Minecraft 帳號。
2. 點選左側邊欄的 **+**（Create new instance / 建立新實例）。
3. 選擇 **Import from file**，選取剛下載的 `mmc3.mrpack`。
4. 等待 Modrinth App 自動下載對應的載入器與模組。

### 方式 B：Prism Launcher

1. 開啟 **Prism Launcher** 並登入你的 Microsoft / Minecraft 帳號。
2. 點選 **Add Instance**（新增實例）→ **Import**（匯入）→ **Browse**（瀏覽），選取剛下載的 `mmc3.mrpack`。
3. 按下 **OK**，等待 Prism Launcher 完成載入器與模組下載。

## 3. 設定遊戲記憶體

第一次啟動遊戲前，請依照 [遊玩指南 — 設定足夠的記憶體](play-guide.zh-TW.md#設定足夠的記憶體) 調整此設定檔的 Java 記憶體配置。

## 4. 加入伺服器

1. 啟動安裝好的設定檔。
2. 進入 **Multiplayer（多人遊戲）**。
3. 伺服器清單已預先填好 **`<伺服器名稱> (<模組包版本>)`**，直接選取並點選 **Join Server（加入伺服器）**。
4. 進入遊戲後，可參考 [遊玩指南 — 進服前幾分鐘怎麼玩](play-guide.zh-TW.md#進服前幾分鐘怎麼玩)。

## 更新模組包

進入遊戲前，在多人遊戲清單比對兩個版本號：

- 預填伺服器名稱括號裡是你目前安裝的版本：`<伺服器名稱> (<你的版本>)`。
- 下方伺服器狀態列（MOTD）顯示的是伺服器目前執行的版本：`<伺服器名稱> | Pack <伺服器版本>`。

只要這兩個版本不同：

1. 使用管理員給你的**同一個固定連結**重新下載最新的 `.mrpack`。
2. 在 Modrinth App 或 Prism Launcher 中安裝成一個**全新的設定檔**（重複上方步驟 2–3）。
3. 啟動新設定檔並加入伺服器。**你的角色進度、建築與道具全都儲存在伺服器上**，安裝新設定檔不會遺失任何存檔。
4. 確認新設定檔能正常連線遊玩後，即可刪除舊的設定檔。

## 疑難排解

- **顯示「You are not white-listed on this server」**：請把你的 Minecraft 精確遊戲 ID 告訴管理員，請對方將你加入白名單。
- **連線時出現版本不符或模組錯誤**：比對預填名稱與 MOTD 上的 `Pack <版本>`，並依照上方 [更新模組包](#更新模組包) 重新下載安裝。
- **驗證帳號失敗（Failed to verify username）**：在啟動器中登出再重新登入 Microsoft 帳號，然後重啟遊戲。
- **無法連線 / 逾時**：確認你安裝的是管理員最新連結的 `.mrpack`（確保內建伺服器位址為最新），並向管理員確認伺服器已開機。
- **載入崩潰或畫面卡頓（FPS 低）**：請參閱 [遊玩指南 — 疑難排解](play-guide.zh-TW.md#疑難排解)。
