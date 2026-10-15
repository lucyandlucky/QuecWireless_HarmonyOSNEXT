import { QuecDeviceListServiceManager } from '@quec/device-list-api'
import { getWindowInsetsState, WindowInsetsState } from '@quec/basic-ui'

/** 首页 Tab 内容，路由栈由主容器管理。 */
@ComponentV2
export struct HomePage {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  @Local private deviceListBuilder: WrappedBuilder<[]> | undefined = undefined

  aboutToAppear(): void {
    this.deviceListBuilder = QuecDeviceListServiceManager.getInstance().getDeviceListBuilder()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Stack() {
        Image($r('app.media.quec_home_header_overlay'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
          .opacity(0.35)
      }
      .width('100%')
      .height(this.windowInsets.top + 112)
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [
          [$r('app.color.quec_home_header_start'), 0],
          [$r('app.color.B1'), 1]
        ]
      })

      Column() {
        Row() {
          Text($r('app.string.quec_home_my_devices'))
            .fontSize(28)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.W1'))
        }
        .width('100%')
        .height(64)
        .padding({ left: 16, right: 16 })

        Column() {
          if (this.deviceListBuilder !== undefined) {
            this.deviceListBuilder.builder()
          } else {
            Text('Device List')
              .fontColor($r('app.color.W2'))
              .fontSize(14)
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ top: this.windowInsets.top })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B1'))
  }
}
