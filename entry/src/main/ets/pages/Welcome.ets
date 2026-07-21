import { AgreementDialog } from '../components/AgreementDialog';

@Entry
@ComponentV2
struct Welcome {
  agreementDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AgreementDialog({
      onAgree: () => {
      },
      onCancel: () => {
      }
    }),
    cancel: this.exitApp,
    autoCancel: false,
    alignment: DialogAlignment.Center,
    backgroundColor: '#FFFFFF'
  })
  private hasShownAgreement: boolean = false

  onPageShow() {
    if (this.hasShownAgreement) {
      return
    }
    this.hasShownAgreement = true
    this.agreementDialogController?.open()
  }

  aboutToDisappear(): void {
    this.agreementDialogController = null
  }

  exitApp() {
    console.log('Click the callback in the blank area')
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