import { AgreementDialog } from '../components/AgreementDialog';
import common from '@ohos.app.ability.common';

@Entry
@ComponentV2
struct Welcome {
  agreementDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AgreementDialog({
      onAgree: () => {
      },
      onCancel: () => {
        this.exitApp()
      }
    }),
    cancel: this.exitApp,
    autoCancel: false,
    width: '80%',
    backgroundColor: $r('app.color.B3'),
    cornerRadius: '16vp',
    alignment: DialogAlignment.Center,
    onWillDismiss: (action) => {
      action.dismiss()
      if (
        action.reason === DismissReason.PRESS_BACK ||
          action.reason === DismissReason.TOUCH_OUTSIDE
      ) {
        this.exitApp()
      }
    }

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
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    context.terminateSelf().catch((err: Error) => {
      console.error(`terminateSelf failed: ${JSON.stringify(err)}`)

    })
  }

  build() {
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