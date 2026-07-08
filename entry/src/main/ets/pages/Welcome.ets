@Entry
@ComponentV2
struct Welcome {
  private hasShownAgreement: boolean = false

  onPageShow() {
    if (this.hasShownAgreement) {
      return
    }
    this.hasShownAgreement = true
    this.getUIContext().showAlertDialog({
      title: '用户协议',
      message: '请你阅读',
      autoCancel: false,
      primaryButton: {
        value: '不同意',
        action: () => {

        }
      },
      secondaryButton: {
        value: '同意',
        action: () => {

        }
      }
    })
  }

  build() {
    // Column()
    //   .width('100%')
    //   .height('100%')
    //   .backgroundImage($r('app.media.app_startup'))
    //   .backgroundImageSize(ImageSize.Cover)
    //   .backgroundImagePosition(Alignment.Center)
    Stack() {
      Image($r('app.media.app_startup'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .height('100%')
  }
}