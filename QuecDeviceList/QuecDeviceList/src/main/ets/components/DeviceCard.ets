import { QuecDeviceModel } from '@quec/device-sdk'

@ComponentV2
export struct DeviceCard {
  @Param device: QuecDeviceModel = {}
  @Local private imageIndex: number = 0

  @Monitor('device')
  private resetImage(): void {
    this.imageIndex = 0
  }

  private imageSources(): ResourceStr[] {
    const sources: ResourceStr[] = []
    if (this.device.logoImage) {
      sources.push(this.device.logoImage)
    }
    if (this.device.productIcon && this.device.productIcon !== this.device.logoImage) {
      sources.push(this.device.productIcon)
    }
    sources.push($r('app.media.quec_device_list_default_icon'))
    return sources
  }

  private isOnline(): boolean {
    return this.device.status !== 2 && this.device.onlineStatus === 1
  }

  private statusText(): ResourceStr {
    if (this.device.status === 2) {
      return $r('app.string.quec_device_invalid')
    }
    if (this.isOnline()) {
      if (this.device.upgradeStatus === 1 ||
        (this.device.userConfirmStatus === 1 && this.device.upgradeStatus === 0)) {
        return $r('app.string.quec_ota_upgrading')
      }
      return $r('app.string.quec_device_online')
    }
    if (this.device.onlineStatus === 0) {
      return $r('app.string.quec_device_offline')
    }
    return ''
  }

  @Builder
  StatusIcon() {
    Stack() {
      Row()
        .width(12)
        .height(12)
        .backgroundColor(this.isOnline() ? $r('app.color.M3') : $r('app.color.W3'))
        .borderRadius(6)
        .opacity(0.2)
      Row()
        .width(5)
        .height(5)
        .backgroundColor(this.isOnline() ? $r('app.color.M3') : $r('app.color.W3'))
        .borderRadius(3)
    }
    .width(12)
    .height(12)
  }

  build() {
    Column() {
      Row() {
        Image(this.imageSources()[this.imageIndex])
          .width(40)
          .height(40)
          .objectFit(ImageFit.Contain)
          .alt($r('app.media.quec_device_list_default_icon'))
          .onError(() => {
            if (this.imageIndex < this.imageSources().length - 1) {
              this.imageIndex++
            }
          })
        Blank()
        if (this.device.isShared) {
          Text($r('app.string.quec_family_share'))
            .fontSize(10)
            .fontColor($r('app.color.W2'))
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .backgroundColor($r('app.color.B1'))
            .borderRadius(4)
        }
      }
      .width('100%')
      .height(40)
      .alignItems(VerticalAlign.Top)

      Blank()

      Column({ space: 2 }) {
        Row({ space: 4 }) {
          this.StatusIcon()
          Text(this.device.deviceName ?? '')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isOnline() ? $r('app.color.W1') : $r('app.color.W3'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        .height(20)

        Text(this.statusText())
          .fontSize(12)
          .fontColor($r('app.color.W3'))
          .height(17)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(120)
    .padding(12)
    .backgroundColor($r('app.color.B2'))
    .borderRadius(12)
    .accessibilityGroup(true)
  }
}
