import { QuecDevicePanelInfo } from '@quec/device-panel-api'
import { QuecRNBundleSource, QuecRNLoadInfo } from '@quec/rn-container'
import { RNOHCoreContext } from '@rnoh/react-native-openharmony'

export class DevicePanelViewModel {
  readonly loadInfo: QuecRNLoadInfo

  private createLoadInfo(info: QuecDevicePanelInfo): QuecRNLoadInfo {
    const metroEnabled: boolean = true
    const coreContext = AppStorage.get<RNOHCoreContext>('RNOHCoreContext')
    const useMetro = metroEnabled && coreContext?.isDebugModeEnabled === true
    const initialProps: Record<string, string> = { 'device': JSON.stringify(info.device) }
    const loadInfo: QuecRNLoadInfo = {
      bundleId: 'device-panel',
      appKey: 'QuecRNAPP',
      bundleSource: useMetro ? QuecRNBundleSource.Metro : QuecRNBundleSource.Resource,
      bundlePath: useMetro ?
        'http://localhost:8081/index.bundle?platform=harmony&dev=true&minify=false' :
        'rn/device-panel/bundle.harmony.js',
      assetsDest: 'rn/device-panel/assets',
      initialProps: initialProps
    }
    return loadInfo
  }

  constructor(info: QuecDevicePanelInfo) {
    this.loadInfo = this.createLoadInfo(info)
  }
}
