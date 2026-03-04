# 艺术字与动效样式配置设计文档

> 创建日期: 2026-03-04
> 状态: 待实现

## 概述

本文档描述横幅应用中艺术字样式和动效参数的配置系统设计。目标是提供丰富的预设风格和深度自定义能力，同时通过订阅机制控制高级功能访问。

---

## 一、艺术字样式配置

### 1.1 预设风格枚举

```swift
enum ArtisticStyle: String, CaseIterable, Codable {
    case none = "普通"

    // 材质类
    case metallic = "金属"
    case glass = "玻璃"
    case wood = "木纹"
    case stone = "石头"

    // 氛围类
    case fire = "火焰"
    case ice = "冰霜"
    case electric = "电流"
    case smoke = "烟雾"

    // 风格类
    case retro = "复古海报"
    case cyberpunk = "赛博朋克"
    case cartoon = "卡通"
    case handwritten = "手写"
    case calligraphy = "书法"

    // 自定义
    case custom = "自定义"
}
```

### 1.2 自定义参数配置

```swift
struct ArtisticStyleConfig: Codable {
    // === 基础层 ===
    var strokeWidth: CGFloat = 0          // 描边粗细
    var strokeColor: Color = .black       // 描边颜色
    var letterSpacing: CGFloat = 0        // 字间距

    // === 阴影 ===
    var shadowOffset: CGSize = .zero      // 阴影偏移 (x, y)
    var shadowBlur: CGFloat = 0           // 阴影模糊度
    var shadowColor: Color = .black       // 阴影颜色

    // === 进阶层 - 渐变与光泽 ===
    var gradientStartColor: Color? = nil  // 渐变起始色
    var gradientEndColor: Color? = nil    // 渐变结束色
    var gradientAngle: Double = 0         // 渐变角度 (度)
    var glossAngle: Double = 45           // 光泽角度 (度)

    // === 高阶层 - 特效 ===
    var embossDepth: CGFloat = 0          // 浮雕深度
    var innerGlowRadius: CGFloat = 0      // 内发光半径
    var outerGlowRadius: CGFloat = 0      // 外发光半径
    var outerGlowColor: Color = .white    // 外发光颜色

    // === 高阶层 - 纹理与高级 ===
    var noiseIntensity: CGFloat = 0       // 噪点强度 (0-1)
    var reflectionOpacity: CGFloat = 0    // 反射效果透明度 (0-1)
    var perspectiveAngle: Double = 0      // 3D透视角度 (度)
}
```

### 1.3 权限控制

- `none` (普通) 样式：免费
- 其他所有预设风格：需订阅
- `custom` 自定义参数：需订阅

---

## 二、动效样式配置

### 2.1 滚动动效配置

```swift
struct ScrollAnimationConfig: Codable {
    var direction: ScrollDirection = .leftToRight
    var startPosition: Double = 0         // 起始位置偏移 (0-1)
    var pauseAtCenter: Bool = false       // 是否在中间暂停
}
```

### 2.2 闪烁动效配置

```swift
struct BlinkAnimationConfig: Codable {
    var frequency: Double = 1.0           // 闪烁频率 (次/秒)
    var minOpacity: Double = 0.3          // 最低透明度 (0-1)
    var maxOpacity: Double = 1.0          // 最高透明度 (0-1)
}
```

### 2.3 呼吸灯动效配置

```swift
struct BreathingAnimationConfig: Codable {
    var minScale: Double = 0.8            // 最小缩放 (0-2)
    var maxScale: Double = 1.2            // 最大缩放 (0-2)
    var minOpacity: Double = 0.5          // 最小透明度 (0-1)
}
```

### 2.4 波浪动效配置

```swift
enum WaveDirection: String, Codable {
    case horizontal = "水平"
    case vertical = "垂直"
}

struct WaveAnimationConfig: Codable {
    var amplitude: Double = 15            // 振幅 (像素)
    var frequency: Double = 0.5           // 频率
    var waveDirection: WaveDirection = .horizontal
}
```

### 2.5 粒子动效配置

```swift
enum ParticleMovement: String, Codable {
    case rise = "上升"
    case fall = "下降"
    case explode = "爆炸"
    case spiral = "螺旋"
}

struct ParticlesAnimationConfig: Codable {
    var particleCount: Int = 30           // 粒子数量 (10-100)
    var particleSizeMin: CGFloat = 2      // 粒子最小尺寸
    var particleSizeMax: CGFloat = 6      // 粒子最大尺寸
    var particleColors: [Color] = [.white, .yellow]  // 粒子颜色
    var movementPattern: ParticleMovement = .rise
}
```

### 2.6 弹跳动效配置

```swift
struct BounceAnimationConfig: Codable {
    var bounceHeight: Double = 20         // 弹跳高度 (像素)
    var elasticity: Double = 0.3          // 弹性系数 (0-1)
    var squashAmount: Double = 0.2        // 挤压变形量 (0-0.5)
}
```

### 2.7 渐变动效配置

```swift
struct GradientAnimationConfig: Codable {
    var gradientColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    var cycleDuration: Double = 3.0       // 循环周期 (秒)
    var blendMode: GradientBlendMode = .normal
}

enum GradientBlendMode: String, Codable {
    case normal = "正常"
    case overlay = "叠加"
    case multiply = "正片叠底"
}
```

### 2.8 逐字显示动效配置

```swift
struct TypewriterAnimationConfig: Codable {
    var charDelay: Double = 0.1           // 每字延迟 (秒)
    var pauseAfterComplete: Double = 2.0  // 完成后暂停 (秒)
    var cursorEnabled: Bool = false       // 是否显示光标
}
```

### 2.9 随机闪现动效配置

```swift
struct RandomFlashAnimationConfig: Codable {
    var flashCount: Int = 5               // 闪现位置数量
    var fadeInDuration: Double = 0.5      // 淡入时长 (秒)
    var fadeOutDuration: Double = 0.3     // 淡出时长 (秒)
    var randomPosition: Bool = true       // 是否随机位置
}
```

### 2.10 LED像素动效配置

```swift
struct LedAnimationConfig: Codable {
    var dotSpacing: CGFloat = 6           // 点间距 (像素)
    var dotSize: CGFloat = 3              // 点大小 (像素)
    var glowIntensity: Double = 0.5       // 发光强度 (0-1)
    var flickerEnabled: Bool = true       // 是否启用闪烁
}
```

### 2.11 权限控制

- 免费动效 (none, scroll, blink, breathing)：可使用默认效果
- **所有动效的参数调整**：需订阅
- 高级动效 (gradient, typewriter, randomFlash, wave, bounce, particles, led)：需订阅

---

## 三、数据模型整合

### 3.1 更新 BannerStyle

```swift
struct BannerStyle: Codable {
    // === 现有字段 (保持不变) ===
    var text: String = ""
    var fontSize: CGFloat = 48.0
    var textColor: Color = .white
    var backgroundColor: Color = .black
    var backgroundType: BackgroundType = .color
    var backgroundImagePath: String? = nil
    var backgroundImageOpacity: Double = 1.0
    var animationType: AnimationType = .none
    var scrollDirection: ScrollDirection = .leftToRight
    var animationSpeed: Double = 1.0
    var isBold: Bool = false
    var fontStyle: FontStyle = .normal

    // === 新增：艺术字配置 ===
    var artisticStyle: ArtisticStyle = .none
    var artisticConfig: ArtisticStyleConfig = .init()

    // === 新增：动效专属配置 ===
    var scrollConfig: ScrollAnimationConfig?
    var blinkConfig: BlinkAnimationConfig?
    var breathingConfig: BreathingAnimationConfig?
    var waveConfig: WaveAnimationConfig?
    var particlesConfig: ParticlesAnimationConfig?
    var bounceConfig: BounceAnimationConfig?
    var gradientConfig: GradientAnimationConfig?
    var typewriterConfig: TypewriterAnimationConfig?
    var randomFlashConfig: RandomFlashAnimationConfig?
    var ledConfig: LedAnimationConfig?
}
```

### 3.2 渲染逻辑

- 当动效 Config 为 `nil` 时，使用默认值
- 当 Config 有值时，使用自定义参数
- `animationSpeed` 作为全局速度因子，与各 Config 参数共同作用

---

## 四、UI 界面设计

### 4.1 StyleSettingsView 新增区域

```
┌─────────────────────────────────────┐
│  ← 样式设置                          │
├─────────────────────────────────────┤
│  [现有区域：文字、颜色、背景等]         │
├─────────────────────────────────────┤
│  ▼ 艺术字样式 (新增)                  │
│  ┌─────────────────────────────────┐│
│  │ 预设风格: [普通 | 艺术字 ▼]       ││
│  │                                 ││
│  │ 当选择"艺术字"时展开：            ││
│  │ ○ 金属  ○ 玻璃  ○ 火焰          ││
│  │ ○ 冰霜  ○ 赛博朋克  ○ 卡通       ││
│  │ ○ 复古  ...  ○ 自定义           ││
│  │                                 ││
│  │ 当选择"自定义"时展开参数面板：     ││
│  │ └─ 描边、阴影、渐变、发光...      ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  ▼ 动效参数 (新增，订阅标识)          │
│  ┌─────────────────────────────────┐│
│  │ 动效类型: [滚动 ▼]               ││
│  │                                 ││
│  │ 滚动专属参数 (👇需订阅):          ││
│  │ ├─ 方向: [← → ▼]                ││
│  │ ├─ 起始位置: ────●──── 0%       ││
│  │ └─ 中间暂停: [开关]              ││
│  │                                 ││
│  │ 切换动效类型时，显示对应参数       ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### 4.2 订阅引导

- 未订阅时：参数区域显示模糊遮罩 + 皇冠图标
- 点击参数区域：弹出 `PremiumUpgradeSheet`
- 已订阅：正常显示和操作所有参数

---

## 五、订阅权限控制

### 5.1 SubscriptionManager 扩展

```swift
extension SubscriptionManager {

    /// 检查艺术字功能是否可用
    func canUseArtisticStyle(_ style: ArtisticStyle) -> Bool {
        switch style {
        case .none:
            return true  // 普通样式免费
        default:
            return isSubscribed  // 所有艺术字样式需订阅
        }
    }

    /// 检查艺术字自定义参数是否可用
    func canUseArtisticCustomization() -> Bool {
        return isSubscribed
    }

    /// 检查动效参数调整是否可用
    func canUseAnimationCustomization() -> Bool {
        return isSubscribed  // 所有参数调整都需要订阅
    }
}
```

---

## 六、实现优先级

### Phase 1: 数据模型
1. 新增 `ArtisticStyle` 枚举
2. 新增 `ArtisticStyleConfig` 结构体
3. 新增各动效 Config 结构体
4. 更新 `BannerStyle`

### Phase 2: 渲染实现
1. 更新 `FontStyleModifier` 支持新艺术字风格
2. 更新 `BannerDisplayView` 各动效视图读取 Config

### Phase 3: UI 实现
1. 在 `StyleSettingsView` 新增艺术字样式区域
2. 在 `StyleSettingsView` 新增动效参数区域
3. 添加订阅权限判断和引导

### Phase 4: 预设风格渲染
1. 实现各预设风格的视觉效果 (金属、火焰等)

---

## 七、文件变更清单

| 文件 | 变更类型 | 说明 |
|------|---------|------|
| `Models/BannerModels.swift` | 修改 | 新增枚举、结构体，更新 BannerStyle |
| `Views/BannerDisplayView.swift` | 修改 | 更新渲染逻辑读取 Config |
| `Views/StyleSettingsView.swift` | 修改 | 新增艺术字和动效参数配置 UI |
| `Managers/SubscriptionManager.swift` | 修改 | 新增权限判断方法 |
