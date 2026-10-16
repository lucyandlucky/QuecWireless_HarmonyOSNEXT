import { HMParamType, HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { getWindowInsetsState, QuecTitleBar, WindowInsetsState } from '@quec/basic-ui'
import { QuecDevicePanelInfo } from '@quec/device-panel-api'

import { DEVICE_PANEL_ROUTE } from '../navigation/QuecDevicePanelRoutes'

@HMRouter({ pageUrl: DEVICE_PANEL_ROUTE })
@ComponentV2
export struct QuecRNPage {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  @Local private info: QuecDevicePanelInfo =
    (HMRouterMgr.getCurrentParam(HMParamType.routeParam) as QuecDevicePanelInfo | null) ?? { device: {} }

  @Builder
  DeviceInfoItem(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.W3'))
      Text(value)
        .fontSize(16)
        .fontColor($r('app.color.W1'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      QuecTitleBar({
        title: '设备面板（占位）',
        onBack: () => HMRouterMgr.pop()
      })
      Scroll() {
        Column({ space: 24 }) {
          this.DeviceInfoItem('设备名称', this.info.device.deviceName ?? '')
          if (this.info.device.productName) {
            this.DeviceInfoItem('产品名称', this.info.device.productName ?? '')
          }
          this.DeviceInfoItem('Product Key', this.info.device.productKey ?? '')
          this.DeviceInfoItem('Device Key', this.info.device.deviceKey ?? '')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(20)
        .backgroundColor($r('app.color.B2'))
        .borderRadius(12)
        .margin({ top: 16, bottom: this.windowInsets.bottom + 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B1'))
  }
}
