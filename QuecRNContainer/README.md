# QuecRNContainer

`@quec/rn-container` 提供可嵌入原生页面或 Tab 的 `QuecRNView`。宿主 Ability 继承 `RNAbility`，并在 entry 配置 RNOH 的 C++ 构建。

每个容器持有一个 `QuecRNController` 和一个独立 RNInstance，bundle 加载成功后通过 RNSurface 展示。bundleId 用于标识业务，不作为实例缓存键；appKey 必须与 JS 注册名一致。

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

- 一个 controller 对应一次容器挂载和一份固定的加载配置；重新打开页面时创建新的 controller。
- `active` 同时反映 Tab 选中状态和外层路由可见性。首次激活才创建实例，暂时隐藏时保留实例；组件销毁时依次释放 Surface 和实例。
- `RNAbility` 转发应用前后台事件。容器切换时仅更新自己的实例，不调用 coreContext.dispatchBackPress 向所有实例广播。
- 路由页面在 onBackPressed 中返回 controller.handleBackPress()；RN 未消费时调用 onBack。原生标题栏可直接关闭路由。
- bundleSource 默认为 Resource，读取 rawfile 相对路径；File 使用沙箱绝对路径；Metro 使用完整 bundle URL。Metro 开发模式会启用调试器，目前未接入 Reload/LogBox 等调试 UI。
- initialProps 的值为字符串，对象参数在业务侧 JSON 序列化。RNInstance/Surface 不在容器之间复用。
- 实例创建后、执行 bundle 前订阅该实例的 RNOH 错误事件，接收 RNOH 上报到该实例的加载和运行错误。错误消息与堆栈写入 `QuecRNController` 标签的 QLog，并通过可选的 `onError` 回调交给业务；释放容器时取消订阅。
- 加载失败或接收到实例错误时，当前激活容器统一通过 `QuecDialog` 弹出“面板加载失败”，只提供“返回”按钮；点击后关闭弹窗并调用 `onBack`，由业务退出面板。重复错误复用同一个弹窗，隐藏或销毁容器时关闭弹窗。Debug 和 Release 都不在 App 界面展示错误消息、堆栈或实例信息；详细信息保留在日志和 `onError` 回调中。

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

## 本地设备面板 bundle

在工程根目录执行，参数填写 RN 工程路径：

```sh
node QuecDevicePanel/QuecDevicePanel/scripts/build-rn-bundle.mjs /path/to/RNProject
```

脚本使用该 RN 工程的 bundle-harmony 命令，将 bundle 和图片输出至设备面板模块的 rawfile/rn/device-panel。构建鸿蒙 HAP 前先执行此步骤；RN 内容更新后重新打包。生成目录已忽略，不提交生成的 JS 和图片。该命令不启动 Metro。

设备面板通过 initialProps.device 传入完整设备 JSON，当前示例注册名为 QuecRNAPP。
