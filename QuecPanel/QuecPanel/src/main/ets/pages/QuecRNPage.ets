import { HMLifecycleState, HMParamType, HMRouter, HMRouterMgr, IHMLifecycleOwner } from '@hadss/hmrouter'
import { getWindowInsetsState, WindowInsetsState } from '@quec/basic-ui'
import { QuecPanelInfo } from '@quec/panel-api'
import { QuecRNController, QuecRNView } from '@quec/rn-container'

import { RN_PAGE_ROUTE } from '../navigation/QuecPanelRoutes'
import { PanelViewModel } from '../viewmodel/PanelViewModel'

@HMRouter({ pageUrl: RN_PAGE_ROUTE, singleton: false })
@ComponentV2
export struct QuecRNPage {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  private info: QuecPanelInfo = HMRouterMgr.getCurrentParam(HMParamType.routeParam) as QuecPanelInfo
  private viewModel: PanelViewModel = new PanelViewModel(this.info)
  @Local private pageVisible: boolean = false
  private controller: QuecRNController = new QuecRNController()
  private lifecycleOwner: IHMLifecycleOwner | null = null

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
