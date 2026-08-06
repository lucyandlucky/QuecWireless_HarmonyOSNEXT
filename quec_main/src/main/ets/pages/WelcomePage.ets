import common from '@ohos.app.ability.common';
import { PolicyRouteParams, PolicySource, PolicyType, PRIVACY_WEBVIEW_ROUTE } from 'quec_privacy_policy';

import { LOGIN_ROUTE } from 'quec_login';
import { QuecAgreementStorage } from '../storage/QuecAgreementStorage';
import { AgreementDialog } from '../components/AgreementDialog';


@Builder
export function WelcomePageBuilder() {
  WelcomePage()
}

@ComponentV2
export struct WelcomePage {
  @Consumer('AppNavigation') navigation: NavPathStack = new NavPathStack()
  private dialogId: number = -1

  @Builder
  agreementDialogBuilder() {
    AgreementDialog({
      onAgree: () => {
        const saved: boolean = QuecAgreementStorage.setHasAgreed(true)
        if (!saved) {
          console.error('Failed to persist the agreement state')
          return
        }
        this.closeAgreementDialog()
        this.resetToLogin()
      },
      onCancel: () => {
        this.exitApp()
      },
      onOpenPolicy: (type: PolicyType, title: ResourceStr) => {
        const params: PolicyRouteParams = {
          source: PolicySource.LATEST,
          type,
          title
        }
        this.navigation.pushPathByName(PRIVACY_WEBVIEW_ROUTE, params)
      }
    })
  }

  private async openAgreementDialog(): Promise<void> {
    if (this.dialogId > 0) {
      return
    }
    const prompt = this.getUIContext().getPromptAction()
    this.dialogId = await prompt.openCustomDialog({
      builder: () => {
        this.agreementDialogBuilder()
      },
      autoCancel: false,
      width: '80%',
      backgroundColor: $r('app.color.B3'),
      cornerRadius: '16vp',
      alignment: DialogAlignment.Center,
      onWillDismiss: () => {
        this.exitApp()
      }
    })
  }

  private closeAgreementDialog(): void {
    if (this.dialogId < 0) {
      return
    }
    this.getUIContext().getPromptAction().closeCustomDialog(this.dialogId)
    this.dialogId = -1
  }

  private resetToLogin(): void {
    const loginPage = new NavPathInfo(
      LOGIN_ROUTE,
      undefined,
      undefined,
      true
    )
    this.navigation.setPathStack([loginPage], false)
  }

  aboutToDisappear(): void {
    this.dialogId = -1
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
    }
    .hideTitleBar(true)
    .onShown(() => {
      // this.agreementDialogController?.open()
      this.openAgreementDialog()

    })
    .onHidden(
      () => {
        // this.agreementDialogController?.close()
        this.closeAgreementDialog()
      }
    )
  }
}