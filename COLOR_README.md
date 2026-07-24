# QuecWireless Color Tokens

本文档说明从 Android `com.quectel.app.basic:quec-ui-config:3.6.0.001-SNAPSHOT`
迁移到 HarmonyOS 的颜色资源。

资源文件：

- 亮色：`entry/src/main/resources/base/element/color.json`
- 暗色：`entry/src/main/resources/dark/element/color.json`

页面始终引用同一个资源名，HarmonyOS 会根据系统颜色模式自动选择亮色或暗色资源：

```typescript
.backgroundColor($r('app.color.B1'))
.fontColor($r('app.color.W1'))
```

## 命名原则

这些名称是从 Android 保留下来的设计令牌，不是按色值深浅简单编号：

- `B`：背景和表面层级，例如页面、导航栏、卡片、弹窗。
- `M`：品牌色、交互状态色和功能色。
- `W`：文字、图标、提示和分割线使用的中性色阶。
- `quec_color_*`：按具体色值保留的补充色或兼容别名。

`B`、`M`、`W` 的英文全称在当前 Android 源码中没有正式定义。上面的含义来自旧版
`ui_config.yml` 注释以及当前业务代码的实际使用方式。

不要因为两个令牌当前色值相同就合并它们。例如亮色下 `B1` 和 `B3` 都是
`#F7F8FC`，但暗色下分别是 `#000000` 和 `#1F1F1F`，代表不同背景层级。

## 背景色 B

| 令牌 | 亮色 | 暗色 | 推荐语义 |
| --- | --- | --- | --- |
| `B1` | `#F7F8FC` | `#000000` | App 页面底色、最底层背景 |
| `B2` | `#FFFFFF` | `#101010` | 主内容表面、导航栏、常规卡片 |
| `B3` | `#F7F8FC` | `#1F1F1F` | 次级表面、搜索框、卡片或弹窗背景；Android `QuecDialog` 使用此色 |
| `B4` | `#FFFFFF` | `#292929` | 更高层的弹窗、输入区域或浮层表面 |
| `B5` | `#FFFFFF` | `#333333` | 底部导航或更高一层的表面，当前使用较少 |
| `B6` | `#E0F2FF` | `#E0F2FF` | 浅蓝强调背景、选中或提示区域，当前使用较少 |

Android 历史设计说明将 `B1-B5` 依次定义为 App 背景、头部导航、卡片、弹窗和底部
导航背景。实际业务代码存在交叉使用，迁移旧页面时应优先保持原页面使用的令牌。

## 主色和状态色 M

| 令牌 | 亮色 | 暗色 | 推荐语义 |
| --- | --- | --- | --- |
| `M0` | `#0091FF` | `#0091FF` | 当前主品牌色，链接、可点击文字、图标 Tint 和选中状态 |
| `M1` | `#0091FF` | `#0091FF` | 主操作色，主要按钮和强调操作 |
| `M2` | `#FF7E27` | `#FF7E27` | 橙色警告、提醒或需要注意的操作 |
| `M3` | `#00CF63` | `#2AEF88` | 成功、开启、在线、推荐等正向状态 |
| `M4` | `#FF3E3E` | `#FF3E3E` | 错误、删除、退出、危险操作 |
| `M5` | `#0091FF` | `#0091FF` | Tab、开关等控件的选中或激活状态 |
| `M6` | `#EFEFEF` | `#9C9FA3` | 中性控件背景、边框、未激活或不可用状态 |

虽然 `M0`、`M1`、`M5` 当前都是 `#0091FF`，仍应按语义分别使用。这样将来只调整按钮色、
链接色或 Tab 选中色时，不需要修改页面代码。

### 主色透明度变体

HarmonyOS 和 Android 都使用 `#AARRGGBB` 表示带透明度的 8 位颜色，最前面的 `AA`
是 Alpha 通道：

| 令牌 | 色值 | 含义 |
| --- | --- | --- |
| `M0_12`、`M0_3` | `#1F0091FF` | 约 12% 不透明度的 `M0` |
| `M0_2`、`M0_48` | `#7A0091FF` | 约 48% 不透明度的 `M0` |
| `M1_12`、`M1_3` | `#1F0091FF` | 约 12% 不透明度的 `M1` |
| `M1_2`、`M1_48` | `#7A0091FF` | 约 48% 不透明度的 `M1` |

这些重复名称来自 Android 历史兼容。迁移旧代码时保留原名称；新代码优先使用名称中
明确包含透明度的 `M0_12`、`M0_48`、`M1_12`、`M1_48`。
`M0_2`、`M0_3`、`M1_2`、`M1_3` 中的数字是遗留编号，不代表 2% 或 3% 透明度。

## 文字和中性色 W

| 令牌 | 亮色 | 暗色 | 推荐语义 |
| --- | --- | --- | --- |
| `W1` | `#080F19` | `#FFFFFF` | 一级文字、标题、主要图标 |
| `W2` | `#6B6F75` | `#A6A6A6` | 正文、二级文字、说明文字 |
| `W3` | `#9C9FA3` | `#737373` | 三级文字、禁用文字、弱提示 |
| `W4` | `#CECFD1` | `#CECFD1` | 更弱的占位文字、未选中状态或滚动条 |
| `W5` | `#9C9FA3` | `#73FFFFFF` | 输入框边线、按压态和低强调控件 |
| `W6` | `#F3F3F4` | `#33FFFFFF` | 分割线、细边框和非常弱的结构线 |

## 补充色

| 令牌 | 亮色 | 暗色 | 说明 |
| --- | --- | --- | --- |
| `quec_color_0091FF` | `#0091FF` | `#0091FF` | 主蓝色兼容别名，新代码优先使用 `M0` 或 `M1` |
| `quec_color_91` | `#91919F` | `#91919F` | 特定中性灰 |
| `quec_color_b3deff` | `#B3DEFF` | `#B3DEFF` | 浅蓝色 |
| `quec_color_bf` | `#BFBFBF` | `#BFBFBF` | 特定浅灰色 |
| `quec_color_cce7ff` | `#CCE7FF` | `#CCE7FF` | 更浅的蓝色背景 |
| `quec_color_ed5d4f` | `#ED5D4F` | `#ED5D4F` | 珊瑚红色 |

这些补充色在 Android 暗色资源中没有单独覆盖，因此 HarmonyOS 暗色资源也沿用亮色值。
由于它们没有稳定的跨页面语义，新代码应优先使用 `B/M/W` 令牌。

## 常见用法

```typescript
// 页面背景
Column() {
  // ...
}
.backgroundColor($r('app.color.B1'))

// 卡片或弹窗背景
.backgroundColor($r('app.color.B3'))

// 标题与正文
Text('Title').fontColor($r('app.color.W1'))
Text('Description').fontColor($r('app.color.W2'))

// 链接与主要操作
Text('Privacy Policy').fontColor($r('app.color.M0'))
Button('Agree').fontColor($r('app.color.M1'))

// 危险操作和分割线
Text('Delete').fontColor($r('app.color.M4'))
Divider().color($r('app.color.W6'))
```

自定义弹窗控制器可以直接引用背景资源：

```typescript
new CustomDialogController({
  builder: AgreementDialog(),
  backgroundColor: $r('app.color.B3')
})
```

## 维护规则

1. 页面中不要新增 `'#FFFFFF'`、`'#0091FF'` 等硬编码颜色，统一引用颜色资源。
2. 同一资源名必须同时存在于 `base` 和 `dark` 的 `color.json` 中。
3. 修改色值时不要因为亮色值相同而合并令牌，要同时检查暗色值和语义。
4. 迁移 Android 页面时保持原令牌；开发全新页面时按本文档中的推荐语义选择。
5. 新增仅用于 HarmonyOS 的颜色时，优先使用可读的语义名称，不再增加按十六进制命名的颜色。
