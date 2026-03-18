# MinerDefender - 功能节点清单

## 核心系统（已有）

### 战斗系统 (`features/battle/`)

| 节点 | 类型 | 说明 |
|------|------|------|
| **BattleUnit** | Node2D | 血量管理、受击、死亡信号。挂在任何实体上赋予 HP |
| **Hurtbox** | Area2D | 受击区域，被 Hitbox 碰到时发出 `hurt` 信号 |
| **Hitbox** | Area2D | 攻击判定区域，碰到 Hurtbox 时触发伤害 |
| **HitAttacker** | Area2D | 继承 Hitbox，带 `atk`/`team`，自动排除同队伤害 |
| **WeaponController** | Node2D | 带冷却的手动射击组件。通过 `ProjectileUtil` 生成弹体，调用 `shoot_in_direction()` |
| **Shooter** | Area2D | 自动寻敌炮塔。检测范围内最近敌人，定时发射弹体 |
| **AutoTargeting** | Area2D | 寻找范围内最近敌人，输出 target |
| **BattleSearch** | Area2D | 敌人用的搜索组件，按 team 过滤 |

### 子弹 (`features/bullet/`)

| 节点 | 类型 | 说明 |
|------|------|------|
| **Bullet** | HitAttacker | 直线飞行弹体，命中后销毁 |

### 矿洞系统 (`features/mine/`)

| 节点 | 类型 | 说明 |
|------|------|------|
| **MineLevel** | Node2D | 矿grid 生成器。配置宽度/深度/矿石概率，生成 MiningBlock 网格 |
| **MiningBlock** | StaticBody2D | 单个矿块。有耐久度、矿石类型，被 `hit()` 后减耐久，破碎后发信号 |
| **BlockConfig** | Resource | 矿块配置：颜色、耐久、矿石类型/数量 |
| **MineSpawnRule** | Resource | 刷怪规则：深度范围、间隔、最大存活数、敌人场景 |

### 敌人 (`features/enemy/` + `features/mine/`)

| 节点 | 类型 | 说明 |
|------|------|------|
| **Enemy** | CharacterBody2D | 俯视角敌人基类（主游戏用） |
| **MineEnemy** | CharacterBody2D | 侧视角矿洞敌人。`flying=false` 时带重力+水平追踪+遇墙跳跃；`flying=true` 时无重力、忽略地形、直飞目标 |
| **MineMonsterSpawner** | Node | 按深度规则刷怪，目标可指向任意 Node2D。生成时自动设置 `flying=true` |

### 建筑 (`features/building/`)

| 节点 | 类型 | 说明 |
|------|------|------|
| **Buildings** | StaticBody2D | 建筑基类：未建/建设中/空闲 状态机 |
| **BuildComponent** | Node2D | 建造交互 UI 组件 |
| **TowerBasic** | Buildings | 基础炮塔建筑 |
| **FarmBasic** | Buildings | 农场建筑（自动产币） |
| **BaseCamp** | Buildings | 基地建筑 |

---

## 新增组件（盾构机玩法）

### 盾构机实体

| 节点 | 类型 | 说明 |
|------|------|------|
| **ShieldMachine** | StaticBody2D | 核心基地实体，替代电梯。持有 BattleUnit（有血量），能力由子节点提供 |

### 可组合功能组件 (`features/mine/components/`)

| 节点 | 类型 | 说明 |
|------|------|------|
| **DrillHead** | Node | 自动钻头。定时攻击下方矿块，整行清除后发出 `row_cleared` 信号 |
| **DescentController** | Node | 下降控制器。监听 DrillHead 的 `row_cleared`，驱动父节点下移一行 |
| **PinballLauncher** | Node2D | 弹球发射器。`auto_fire=true` 时定时自动发射；`auto_fire=false` 时响应鼠标左键点击发射（带冷却）。通过 `ProjectileUtil` 生成弹体 |
| **JetpackController** | Node | 喷气背包。长按跳跃键向上推进，有燃料消耗和回复系统 |

### 弹球弹体

| 节点 | 类型 | 说明 |
|------|------|------|
| **Pinball** | CharacterBody2D | 反弹弹体。使用 `move_and_collide` 实现真实反弹物理，碰墙反射。同时伤害矿块（`hit()`）和敌人（HitAttacker）。支持 `exclude_body` 排除发射源碰撞 |

---

## 场景组合

### Mode 2：盾构机 + 弹球（无玩家）
`scenes/mine/mine_mode2.tscn`

盾构机位于最顶部，MineLevel 地形紧贴其下方生成（无竖井）。鼠标点击发射弹球。怪物从上方飞行接近。

```
ShieldMachine (y=0, 居中)
├── DrillHead       ← 自动向下钻
├── DescentController ← 钻通后下降
├── PinballLauncher ← 鼠标点击发射弹球（auto_fire=false）
├── Camera2D        ← 镜头跟随
└── BattleUnit      ← 基地血量
MineLevel (y=CELL_SIZE, 紧贴盾构机下方)
MineMonsterSpawner (flying 敌人从上方进攻)
```

### Mode 1：玩家 + 盾构机
`scenes/mine/mine_mode1.tscn`

盾构机居顶，玩家在其上方。地形从盾构机下方开始。

```
ShieldMachine (y=0, 居中)
├── DrillHead       ← 自动向下钻
├── DescentController ← 钻通后下降
└── BattleUnit      ← 基地血量
Miner (y=-32, 盾构机上方)
├── JetpackController ← 喷气背包
├── WeaponController  ← 鼠标射击
└── 鼠标挖矿
MineLevel (y=CELL_SIZE, 紧贴盾构机下方)
MineMonsterSpawner (flying 敌人从上方进攻)
```

---

## 公共工具 (`core/systems/`)

| 工具类 | 说明 |
|--------|------|
| **ProjectileUtil** | 静态弹体生成工具。统一处理实例化、位置、方向、速度、team、instigator、exclude_body。被 WeaponController 和 PinballLauncher 共用 |

## 全局系统 (`core/autoloads/`)

| 单例 | 说明 |
|------|------|
| **GlobalObjects** | 全局对象注册表 |
| **GlobalSignal** | 全局信号总线 |
| **GlobalInfo** | 全局枚举/常量（Team 等） |
| **AppLogger** | 标准化日志 `[模块] 消息` |
| **CommandRouter** | 调试命令路由 |
