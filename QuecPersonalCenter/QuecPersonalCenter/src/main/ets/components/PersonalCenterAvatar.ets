import { QuecUserModel } from '@quec/user-sdk'

@ComponentV2
export struct PersonalCenterAvatar {
  @Param user: QuecUserModel | undefined = undefined
  @Param avatarSize: number = 64
  @Param avatarBorderWidth: number = 1
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
    Image(this.avatar())
      .width(this.avatarSize)
      .height(this.avatarSize)
      .objectFit(ImageFit.Cover)
      .borderRadius(this.avatarSize / 2)
      .border({ width: this.avatarBorderWidth, color: $r('app.color.W6') })
      .alt($r('app.media.quec_personal_center_default_head'))
      .onError(() => this.imageFailed = true)
  }
}
