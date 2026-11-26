# 遊玩指南

*（English version: [docs/play-guide.md](play-guide.md)）*

> **還沒安裝模組包嗎？** 請先依照 [模組包安裝與更新指南](pack-install-guide.zh-TW.md) 完成下載與安裝，第一次開遊戲前再回到本頁。

## 電腦需求

- **Java 21**（Minecraft 1.21.1 與 Fabric 0.20.1 需要 Java 21；Modrinth App 與 Prism Launcher 皆可自動下載）。
- 建議電腦至少具備 **8 GB 系統記憶體**（若想搭配 Iris 開啟光影，建議 16 GB 以上）。

## 設定足夠的記憶體

請為遊戲配置 **最低 4 GB**、**建議 6 GB**，且**不要超過 8 GB**（分配超過 8 GB 反而容易造成 Java 垃圾回收頓挫）。

- **Modrinth App**：點開實例 → **Settings（齒輪）** → **Java and memory** → 啟用 **Custom memory allocation** → 設為 **6144 MB**（6 GB；若電腦只有 8 GB RAM 則設為 **4096 MB**），並確認 Java 版本為 **Java 21**。
- **Prism Launcher**：選取實例 → **Edit（編輯）** → **Settings（設定）** → **Java** → 勾選 **Memory（記憶體）** → **Minimum** 設為 `2048 MiB`、**Maximum** 設為 `6144 MiB`（8 GB 電腦設 `4096 MiB`），並選取 **Java 21**。

## 進服前幾分鐘怎麼玩

1. **隨時用 EMI 查配方**：按 **`E`** 開啟背包，在右側 **EMI** 搜尋欄輸入任何裝備、料理或法術書名稱；左鍵看合成表，游標移到物品上按 **`U`** 可看用途。
2. **熟悉動作戰鬥與翻滾（Better Combat + Combat Roll）**：製作你的第一把近戰武器（長劍、長槍、斧、匕首、大劍等），**Better Combat** 會提供連擊揮砍動作與範圍判定；按 **`R`** 可發動 **Combat Roll** 翻滾閃避。
3. **選擇 RPG 職業路線（RPG Series + Spell Engine）**：
   - 製作 **Spell Binding Table（法術綁定台）** 與 **Runes（符文）**（可用 EMI 查合成），將法術綁定到各職業法術書上：
     - **Wizards（法師）**：火焰、冰霜、秘法法杖與法袍
     - **Paladins & Priests（聖騎士／牧師）**：盾牌、戰錘、神聖治療與防護法術
     - **Archers（弓手）**：長弓、弩與遠程技能
     - **Rogues & Warriors（盜賊／戰士）**：匕首、鐮刀、潛行與近戰戰技
   - 施法時背包內需備妥對應**符文（Runes）**；也可在飾品欄（Trinkets）裝備 **Jewelry（珠寶）** 與 **Relics（遺物）** 獲得被動強化。
4. **整備遠征裝備**：
   - 製作 **Traveler's Backpack（旅人背包）** 裝備在背後，隨時按 **`B`** 開啟。
   - 在村莊（`Towns and Towers`）啟用或自製 **Waystones（傳送碑）**，快速在隊友基地與地城之間傳送。
   - 用 **Farmer's Delight（農夫樂事）** 的烹飪鍋製作中世紀料理，獲得更高的飽食度與營養增益。
5. **探索地城與挑戰終局 Boss**：
   - 探索 **Dungeons and Taverns**、**YUNG's Better Dungeons**、**Better Nether Fortresses** 與 **Better Strongholds** 重製後的多層地城與要塞。
   - 不小心陣亡時，**You're in Grave Danger** 會把你的裝備安全保存在死亡地點的墓碑中，回去互動即可領回全部道具。
   - 進入終界不再靠原版終界之眼：**End Remastered** 需要從各地地城、結構與 Boss 收集 **12 顆不同的終界之眼**；同時還有 **Bosses of Mass Destruction** 的 4 隻大型 Boss（Night Lich、Void Blossom、Nether Gauntlet、Obsidilith）等你和朋友組隊挑戰。

## 常用按鍵

| 按鍵 | 功能 | 模組 |
|---|---|---|
| `B` | 開啟旅人背包 | Traveler's Backpack |
| `N` | 新增小地圖路徑點*（已從 `B` 移開，避免與背包衝突）* | Xaero's Minimap |
| `M` | 開啟全螢幕世界地圖 | Xaero's World Map |
| `R` | 翻滾閃避 | Combat Roll |
| `E` | 開啟背包與 EMI 配方搜尋 | Minecraft / EMI |
| `U` | 查看物品用途（游標指在 EMI 物品上） | EMI |

## 疑難排解

- **遊戲載入時崩潰**：
  1. 確認設定檔使用 **Java 21**（舊版 Java 無法啟動 Minecraft 1.21.1）。
  2. 將最大記憶體設為建議值 **6 GB**（`6144 MB`）。
  3. 更新顯示卡驅動程式（NVIDIA、AMD 或 Intel）。
- **畫面卡頓 / FPS 過低**：
  1. 若你透過 **Iris Shaders** 開啟了光影，請先關閉光影或改用較輕量的光影包。
  2. 在顯示設定中將 **視野距離（Render Distance）** 從 `10` 降到 `8`、**模擬距離（Simulation Distance）** 從 `6` 降到 `5`。
  3. 確認最大記憶體維持在 `6 GB`（不要超過 `8 GB`）。
- **法術或 RPG 技能無法施放**：
  1. 確認已透過 **Spell Binding Table** 將法術綁定在法術書上，且手持對應職業的法杖或武器。
  2. 確認背包內有足夠的對應**符文（Runes）**。
  3. 到 **Options → Controls → Key Binds** 檢查 *Spell Engine* 與 *Combat Roll* 的按鍵是否有被其他自訂按鍵覆蓋。
