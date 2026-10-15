import { QuecUserModel } from '@quec/user-sdk'

@ComponentV2
export struct PersonalCenterHeader {
  @Param user: QuecUserModel | undefined = undefined
  @Event onHeadClick: () => void = () => {
  }
  @Local private imageFailed: boolean = false

  @Monitor('user')
  private resetAvatar(): void {
    this.imageFailed = false
  }

  private avatar(): ResourceStr {
    const url: string = this.user?.headimg ?? ''
    return !this.imageFailed && url.length > 0 ? url : $r('app.media.quec_personal_center_default_head')
  }

  build() {
    Row({ space: 12 }) {
      Image(this.avatar())
        .width(64)
        .height(64)
        .objectFit(ImageFit.Cover)
        .borderRadius(32)
        .border({ width: 1, color: $r('app.color.W6') })
        .alt($r('app.media.quec_personal_center_default_head'))
        .onError(() => this.imageFailed = true)
      Column({ space: 4 }) {
        Text(this.user?.nikeName ?? '')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .lineHeight(22)
          .fontColor($r('app.color.W1'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text($r('app.string.quec_user_remind'))
          .fontSize(12)
          .lineHeight(17)
          .fontColor($r('app.color.W3'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(64)
    .padding({ left: 8, right: 8 })
    .onClick(() => this.onHeadClick())
    .accessibilityGroup(true)
  }
}
