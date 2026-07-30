import { AgreementDialog } from '../components/AgreementDialog';
import common from '@ohos.app.ability.common';

interface PolicyWebViewParams {
  url: string
}

@Builder
export function WelcomePageBuilder() {
  WelcomePage()
}

@ComponentV2
export struct WelcomePage {
  @Consumer('AppNavigation') navigation: NavPathStack = new NavPathStack()
  agreementDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AgreementDialog({
      onAgree: () => {
      },
      onCancel: () => {
        this.exitApp()
      },
      onOpenPolicy: (url: string) => {
        const params: PolicyWebViewParams = {
          url
        }
        this.navigation.pushPathByName('QuecPrivacyWebViewPage', params)
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
    NavDestination() {
      Stack() {
        Image($r('app.media.quec_app_welcome_page'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
      .width('100%')
      .height('100%')
      .onAppear(() => {
        if (this.hasShownAgreement) {
          return
        }
        this.hasShownAgreement = true
        this.agreementDialogController?.open()
      })
    }
  }
}