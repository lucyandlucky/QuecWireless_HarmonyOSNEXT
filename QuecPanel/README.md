# QuecPanel

`QuecPanelApi`（`@quec/panel-api`）提供面板输入 `QuecPanelInfo` 和服务入口。`QuecPanel`（`@quec/panel`）提供路由页面 `QuecRNPage`、页面 ViewModel 和服务实现；宿主应用依赖实现模块，业务调用方依赖 API 模块。

## 打开面板

设备列表使用已取得的设备模型打开面板：

```ts
import { QuecPanelServiceManager } from '@quec/panel-api'

QuecPanelServiceManager.getInstance().loadPanel({ device: device })
```

调用流程：

```text
业务调用方
  → QuecPanelServiceManager.loadPanel(QuecPanelInfo)
  → QuecPanelServiceImpl 将业务参数传给 QuecRNPage
  → 页面创建并持有 PanelViewModel
  → ViewModel 准备 QuecRNLoadInfo
  → QuecRNView 加载和展示
```

服务负责面板入口和跳转。页面持有自己的 ViewModel、controller 和路由生命周期；ViewModel 负责业务参数到加载信息的转换。RN 实例、bundle 加载、RNSurface、开发进度和错误界面由 `QuecRNContainer` 管理。

`QuecRNPage` 使用 `singleton: false`，同一路由可以多次入栈。每个页面实例持有各自的业务参数和 RNInstance；打开面板 B 后，`pop()` 返回面板 A。

当前 `QuecPanelInfo` 保留已有的设备输入，加载现有示例 bundle。业务面板的 `panelId` 输入、云端面板配置、多语言与下载准备后续在本模块扩展。

## 本地 bundle 和 Metro

`QuecPanel/src/main/ets/viewmodel/PanelViewModel.ets` 的 `createLoadInfo()` 使用本地变量 `metroEnabled` 选择加载来源：

- `true` 且 RNOH 确认为 Debug 包：使用 `http://localhost:8081/index.bundle?platform=harmony&dev=true&minify=false`。
- `false` 或 Release 包：使用 rawfile 中的 `rn/device-panel/bundle.harmony.js`。

两种来源使用同一个 `QuecRNAPP` 注册名、设备初始参数和资源目录。设备对象在 ViewModel 中序列化为 `initialProps.device`。变量或 URL 修改后需要重新构建 HAP；加载信息在页面初始化时确定，重新进入页面后生效。

Metro 端口转发、刷新、进度和错误显示说明见 [QuecRNContainer](../QuecRNContainer/README.md)。

## 打包设备示例 bundle

在鸿蒙工程根目录执行，参数填写 RN 工程路径：

```sh
node QuecPanel/QuecPanel/scripts/build-rn-bundle.mjs /path/to/RNProject
```

脚本调用 RN 工程的 `bundle-harmony` 命令，将 bundle 和图片输出到 `QuecPanel/src/main/resources/rawfile/rn/device-panel`。构建本地 bundle 模式的 HAP 前执行此步骤；RN 内容更新后重新打包。生成的 JS 和图片目录已忽略，该命令不启动 Metro。
