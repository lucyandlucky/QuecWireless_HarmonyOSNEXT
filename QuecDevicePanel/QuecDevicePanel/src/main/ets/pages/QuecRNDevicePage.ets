import { HMLifecycleState, HMParamType, HMRouter, HMRouterMgr, IHMLifecycleOwner } from '@hadss/hmrouter'
import { getWindowInsetsState, WindowInsetsState } from '@quec/basic-ui'
import { QuecDevicePanelInfo } from '@quec/device-panel-api'
import { QuecRNController, QuecRNView } from '@quec/rn-container'

import { DEVICE_PANEL_ROUTE } from '../navigation/QuecDevicePanelRoutes'
import { DevicePanelViewModel } from '../viewmodel/DevicePanelViewModel'

@HMRouter({ pageUrl: DEVICE_PANEL_ROUTE })
@ComponentV2
export struct QuecRNDevicePage {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  @Local private info: QuecDevicePanelInfo =
    (HMRouterMgr.getCurrentParam(HMParamType.routeParam) as QuecDevicePanelInfo | null) ?? { device: {} }
  @Local private pageVisible: boolean = false
  private controller: QuecRNController = new QuecRNController()
  private lifecycleOwner: IHMLifecycleOwner | null = null
  private viewModel: DevicePanelViewModel = new DevicePanelViewModel(this.info)

  private onPageShown = (): void => {
    this.pageVisible = true
  }
  private onPageHidden = (): void => {
    this.pageVisible = false
  }
  private onBackPressed = (): boolean => this.pageVisible && this.controller.handleBackPress()

  aboutToAppear(): void {
    this.lifecycleOwner = HMRouterMgr.getCurrentLifecycleOwner()
    this.lifecycleOwner?.addObserver(HMLifecycleState.onShown, this.onPageShown)
    this.lifecycleOwner?.addObserver(HMLifecycleState.onHidden, this.onPageHidden)
    this.lifecycleOwner?.addObserver(HMLifecycleState.onBackPressed, this.onBackPressed)
  }

  aboutToDisappear(): void {
    this.lifecycleOwner?.removeObserver(HMLifecycleState.onShown, this.onPageShown)
    this.lifecycleOwner?.removeObserver(HMLifecycleState.onHidden, this.onPageHidden)
    this.lifecycleOwner?.removeObserver(HMLifecycleState.onBackPressed, this.onBackPressed)
    this.lifecycleOwner = null
  }

  build() {
    Column() {
      Column() {
        QuecRNView({
          info: this.viewModel.loadInfo,
          controller: this.controller,
          active: this.pageVisible,
          onBack: () => HMRouterMgr.pop()
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ bottom: this.windowInsets.bottom })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B1'))
  }
}
