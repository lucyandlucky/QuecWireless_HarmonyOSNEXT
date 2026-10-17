# QuecRNContainer

`@quec/rn-container` 提供可嵌入原生页面或 Tab 的 `QuecRNView`、`QuecRNController` 和加载信息类型 `QuecRNLoadInfo`。宿主 Ability 继承 `RNAbility`，并在 entry 配置 RNOH 的 C++ 构建。

每个容器持有一个 `QuecRNController` 和一个独立 RNInstance，bundle 加载成功后通过 RNSurface 展示。bundleId 用于标识业务，不作为实例缓存键；appKey 必须与 JS 注册名一致。

## 全屏面板

全屏路由页面 `QuecRNPage` 属于 [QuecPanel](../QuecPanel/README.md)。调用方通过 `@quec/panel-api` 的 `QuecPanelServiceManager` 传入业务参数；进入页面后，由页面持有的 `PanelViewModel` 准备 `QuecRNLoadInfo`，再交给 `QuecRNView` 展示。

`QuecRNContainer` 根据加载信息管理 RN 运行过程；面板输入解析、加载配置和路由页面由 `QuecPanel` 管理。

## 嵌入页面或 Tab

页面或 Tab 在各自的组件中创建 controller，直接嵌入 `QuecRNView`：

```ts
private rnController: QuecRNController = new QuecRNController()
private rnInfo: QuecRNLoadInfo = this.createRNInfo()

private createRNInfo(): QuecRNLoadInfo {
  const initialProps: Record<string, string> = { 'device': JSON.stringify(device) }
  const info: QuecRNLoadInfo = {
    bundleId: 'device-panel',
    appKey: 'QuecRNAPP',
    bundlePath: 'rn/device-panel/bundle.harmony.js',
    assetsDest: 'rn/device-panel/assets',
    initialProps: initialProps
  }
  return info
}
```

```ts
QuecRNView({
  info: this.rnInfo,
  controller: this.rnController,
  active: this.pageVisible,
  onBack: () => HMRouterMgr.pop()
})
```

- 一个 controller 对应一次容器挂载和一份固定的加载配置；重新打开页面时创建新的 controller。Metro 完整 Reload 保留 controller，重建 RNInstance 和 Surface。
- `active` 同时反映 Tab 选中状态和外层路由可见性。首次激活才创建实例，暂时隐藏时保留实例；组件销毁时依次释放 Surface 和实例。
- `RNAbility` 转发应用前后台事件。容器切换时仅更新自己的实例，不调用 coreContext.dispatchBackPress 向所有实例广播。
- 路由页面在 onBackPressed 中返回 controller.handleBackPress()；RN 未消费时调用 onBack。原生标题栏可直接关闭路由。
- bundleSource 默认为 Resource，读取 rawfile 相对路径；File 使用沙箱绝对路径；Metro 使用完整 bundle URL。Debug 下的 Metro 实例启用调试器，Fast Refresh 由 RNOH 配置；当前激活的 Metro 容器监听 RNOH 的 RELOAD 事件，支持 Metro 终端按 r 完整重载。
- initialProps 的值为字符串，对象参数在业务侧 JSON 序列化。RNInstance/Surface 不在容器之间复用。
- 实例创建后、执行 bundle 前订阅该实例的 RNOH 错误事件，接收 RNOH 上报到该实例的加载和运行错误。错误消息与堆栈写入 `QuecRNController` 标签的 QLog，并通过可选的 `onError` 回调交给业务；释放容器时取消订阅。
- 本地 Resource / File bundle 加载失败或接收到实例错误时，当前激活容器通过 `QuecDialog` 弹出“面板加载失败”，只提供“返回”按钮；点击后关闭弹窗并调用 `onBack`，由业务退出面板。重复错误复用同一个弹窗，隐藏或销毁容器时关闭弹窗。详细信息保留在日志和 `onError` 回调中。

```ts
QuecRNView({
  info: this.rnInfo,
  controller: this.rnController,
  active: this.pageVisible,
  onBack: () => HMRouterMgr.pop(),
  onError: (error: QuecRNError) => {
    // 业务错误处理。
  }
})
```

本地生产模式 bundle 的日志堆栈位置对应打包产物；定位到原始 TSX 行号需要匹配的 source map，或使用 Metro 开发模式。

## Metro 调试

全屏面板的加载来源在 `QuecPanel/QuecPanel/src/main/ets/viewmodel/PanelViewModel.ets` 的 `createLoadInfo()` 中准备，通过本地变量 `metroEnabled` 选择。变量为 `true` 且 RNOH 确认是 Debug 包时使用 Metro；变量为 `false` 或 Release 包时使用包内 rawfile。加载信息在页面初始化时确定，切换来源后重新进入页面生效。配置说明见 [QuecPanel](../QuecPanel/README.md)。

USB 连接设备后执行：

```sh
hdc rport tcp:8081 tcp:8081
```

在 RN 工程目录启动 Metro：

```sh
cd /Users/lucy/study/harmony/RN_project/AwesomeProject
yarn start
```

进入设备面板后，保存 JS/TSX 改动可通过 Fast Refresh 更新；在 Metro 终端按 `r` 完整重载。重载先卸载旧 RNSurface，再通过 RNOH 的 `reloadRNInstance()` 重建实例以保留 DevTools 连接，随后重新执行 bundle 并挂载 Surface。并发 Reload 请求合并，页面退出时取消 RELOAD 订阅并释放资源。首次加载失败后仍可接收 RELOAD，以便修正编译错误后重试。

Debug 的 Metro 容器在顶部展示官方 `RNDevLoadingView`。该组件独立于 RNSurface 挂载，首次加载等待进度组件挂载后再启动，避免错过加载开始事件。Metro 请求通过 `QuecMetroJSBundleProvider` 接收 `multipart/mixed` 响应：构建阶段显示 `Building` 百分比和模块数量，下载阶段显示 `Downloading` 百分比；服务器未提供长度时显示已接收的 KB。首次加载和完整 Reload 使用同一套进度，结束或失败时由 SDK 自动隐藏。Fast Refresh 继续显示 SDK 的 `Refreshing...`。最终分段的状态码和错误正文继续交给 SDK 解析并展示 Metro 编译错误。

Metro 模式不显示“面板加载失败”通用弹窗。开发 bundle 的 JS 错误使用 RN LogBox，支持点击错误提示查看完整堆栈；bundle 请求、编译等 RNOH 错误使用 Debug 下的官方 `RNOHErrorDialog`。完整 Reload 会先关闭开发错误界面，再重建实例，避免旧 LogBox Surface 残留。JS 开发错误由 LogBox 接管，不保证经过容器的 `onError` 回调。

使用局域网调试时，将 URL 中的 localhost 替换为电脑局域网 IP，并用 `yarn start --host 0.0.0.0` 启动 Metro；设备和电脑需要能互相访问。Metro 模式下 bundle 和静态图片由开发服务器提供，修改 RN 内容无需重新打包复制到 rawfile。其他页面或 Tab 同样通过各自的 `QuecRNLoadInfo` 指定加载来源和地址。

本地设备面板 bundle 的打包脚本和资源位于 `QuecPanel`，使用方式见 [QuecPanel](../QuecPanel/README.md)。
