import { QuecDeviceListServiceManager } from '@quec/device-list-api'

/** 首页 Tab 内容，路由栈由主容器管理。 */
@ComponentV2
export struct HomePage {
  @Local private deviceListBuilder: WrappedBuilder<[]> | undefined = undefined

  aboutToAppear(): void {
    this.deviceListBuilder = QuecDeviceListServiceManager.getInstance().getDeviceListBuilder()
  }

  build() {
    Column() {
      if (this.deviceListBuilder !== undefined) {
        this.deviceListBuilder.builder()
      } else {
        Text($r('app.string.quec_device_list'))
          .fontColor($r('app.color.W2'))
          .fontSize('14fp')
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.B1'))
  }
}
