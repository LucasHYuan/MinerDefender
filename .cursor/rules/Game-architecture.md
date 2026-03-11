## MinerDefender Godot4 项目结构规则（给 AI）

**项目类型**：Godot 4 + GDScript 的 2D 游戏，核心循环为“探索刷怪 → 回城建造/塔防 → 强化再出战”。  
**根目录**：`Game`（Godot 项目根在 `Game/project.godot`）。

当你在本项目中创建或修改脚本/场景时，请严格遵守以下规则：

---

### 1. 顶层目录选择

根据要实现的功能，优先选择如下目录（如不存在可假设将来会按此结构迁移）：

- **全局入口或系统** ⇒ 放在 `Game/core/` 下：
  - 入口/主场景：`Game/core/main/`
  - 系统控制器（昼夜循环、波次控制等）：`Game/core/systems/`
  - Autoload 单例（信号总线、全局对象、全局配置）：`Game/core/autoloads/`

- **关卡/大场景组合** ⇒ 放在 `Game/scenes/` 下：
  - 探索刷怪关卡：`Game/scenes/explore/`
  - 家园/基地建造场景：`Game/scenes/home/`
  - 塔防关卡：`Game/scenes/defense/`
  - 场景自身只负责“装配和调度”，具体单位逻辑从 `features/` 引用

- **领域逻辑（Feature）** ⇒ 放在 `Game/features/<domain>/` 下：
  - 玩家：`Game/features/player/`
  - 敌人与波次：`Game/features/enemy/`
  - 建筑与塔：`Game/features/building/`
  - 战斗系统（通用战斗逻辑）：`Game/features/battle/`
  - 子弹与发射器：`Game/features/bullet/`

- **UI 与调试界面** ⇒ 放在 `Game/ui/` 下：
  - HUD/状态条：`Game/ui/hud/`
  - 输入相关 UI（如虚拟摇杆）：`Game/ui/input/`
  - 调试与 GM 工具：`Game/ui/debug/`

- **共享工具类与资源** ⇒ 放在 `Game/shared/` 下：
  - 通用组件/工具类（不专属某个 Feature）：`Game/shared/classes/`
  - 通用 .tres 资源与数据配置：`Game/shared/resources/`

> 规则：**不要**在 `Game` 根目录直接新增领域脚本或场景；请放入上述合适的子目录中。

---

### 2. 命名与 `class_name` 约定

#### 2.1 场景与脚本配对

- 新建 `.tscn` 场景时，应在同一目录下创建同名或对应的 `.gd` 脚本：
  - 推荐：`PascalCase` 场景，`snake_case` 脚本文件  
    - 例如：`TowerBasic.tscn` ↔ `tower_basic.gd`

#### 2.2 类名与文件名

- 类名（`class_name`）统一使用 `PascalCase`，并在重要脚本中声明：
  - `class_name Player`
  - `class_name MonsterGenerator`
  - `class_name BattleUnit`
- GDScript 文件名使用 `snake_case.gd`，风格统一：
  - `Player` → `player.gd`
  - `MonsterGenerator` → `monster_generator.gd`
  - `BattleUnit` → `battle_unit.gd`

---

### 3. 全局访问与信号

- **全局信号**：统一在 `Game/core/autoloads/global_signal.gd` 中管理
  - 新增或使用全局信号时，应通过 `GlobalSignal` 单例，而不是在任意脚本中随意声明
- **全局对象**：统一使用 `GlobalObjects` 管理
  - 存储：`GlobalObjects.SetObject("key", node)`
  - 读取：`GlobalObjects.GetObject("key")`
  - 避免在生成代码中使用深层级硬编码路径（例如 `get_node("../../../../Player")`）

---

### 4. 战斗与数值逻辑组织

- 通用战斗与数值逻辑应放在 `Game/features/battle` 下：
  - 单位载体：`battle_unit.tscn` / `battle_unit.gd`
  - 攻击与命中逻辑：`attack_item.gd`, `hit_attacker.gd`
  - 碰撞与伤害数据结构：`Hitbox.gd`, `Hurtbox.gd`, `Damage.gd`
  - 技能/效果：`skills/` 子目录
- 当需要为 Player/Enemy/Building 添加战斗能力时：
  - 应通过**组合** `BattleUnit`、Hitbox/Hurtbox 等组件
  - 不要在这些对象各自重新实现独立的 HP/伤害/死亡逻辑

---

### 5. 场景循环划分

本游戏核心有三种关键场景循环，命名上应保持清晰：

- 探索场景（刷怪/外出战斗）：
  - 主场景示例：`ExploreMain.tscn` / `explore_main.gd`
  - 所在目录：`Game/scenes/explore/`
- 家园场景（建造/准备）：
  - 主场景示例：`HomeMain.tscn` / `home_main.gd`
  - 所在目录：`Game/scenes/home/`
- 塔防场景：
  - 主场景示例：`DefenseMain.tscn` / `defense_main.gd`
  - 所在目录：`Game/scenes/defense/`

当需要新增与这三种循环相关的场景时，请命名为 `SomethingMain` 或带有明确的功能前缀（例如 `explore_forest_01.tscn`），并放到对应子目录。

---

### 6. 为 AI 生成代码时的具体指引

当你（AI）在本项目生成新代码时，应遵循：

1. **先选目录，再写代码**  
   - 根据功能先决定是 `core/`、`scenes/`、`features/`、`ui/` 还是 `shared/`  
   - 不要在生成代码时随意创建新的顶层目录；优先使用现有结构

2. **保持现有风格**  
   - 使用 GDScript，遵循 `class_name` + `snake_case.gd` 的习惯  
   - 引用现有类型时优先使用 `class_name`（如 `BattleUnit`, `PlayerData`）

3. **依赖关系处理**  
   - 跨 Feature 或场景的通信优先使用：信号、Autoload 单例、组合组件  
   - 减少直接获取深层节点路径的写法，避免未来目录调整导致路径大量失效

4. **遵守 `CODE_RULES.md`**  
   - 本文件是机器视角下的精简版本，详细的人类可读说明在仓库根的 `CODE_RULES.md`  
   - 如果两者存在不一致，以 `CODE_RULES.md` 为准，并同时更新两份说明

