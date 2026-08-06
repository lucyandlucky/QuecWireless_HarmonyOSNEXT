import common from '@ohos.app.ability.common';
import { PolicyRouteParams, PolicySource, PolicyType, PRIVACY_WEBVIEW_ROUTE } from 'quec_privacy_policy';
import { HMLifecycleState, HMRouter, HMRouterMgr, IHMLifecycleOwner } from '@hadss/hmrouter';

import { LOGIN_ROUTE } from 'quec_login';
import { QuecAgreementStorage } from '../storage/QuecAgreementStorage';
import { AgreementDialog } from '../components/AgreementDialog';
import { WELCOME_ROUTE } from '../model/QuecMainRoute';


@HMRouter({ pageUrl: WELCOME_ROUTE })
@ComponentV2
export struct WelcomePage {
  private lifecycleOwner: IHMLifecycleOwner | null = null
  private dialogId: number = -1

  aboutToAppear(): void {
    this.lifecycleOwner = HMRouterMgr.getCurrentLifecycleOwner()
    this.lifecycleOwner?.addObserver(
      HMLifecycleState.onShown,
      this.onPageShown
    )
    this.lifecycleOwner?.addObserver(
      HMLifecycleState.onHidden,
      this.onPageHidden
    )
  }

  aboutToDisappear(): void {
    this.lifecycleOwner?.removeObserver(
      HMLifecycleState.onShown,
      this.onPageShown
    )
    this.lifecycleOwner?.removeObserver(
      HMLifecycleState.onHidden,
      this.onPageHidden
    )
    this.closeAgreementDialog()
    this.lifecycleOwner = null
  }

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
        HMRouterMgr.push({
          pageUrl: PRIVACY_WEBVIEW_ROUTE,
          param: params
        })
      }
    })
  }

  private exitApp() {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    context.terminateSelf().catch((err: Error) => {
      console.error(`terminateSelf failed: ${JSON.stringify(err)}`)
    })
  }

  private onPageShown = (): void => {
    this.openAgreementDialog()
  }
  private onPageHidden = (): void => {
    this.closeAgreementDialog()
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
    HMRouterMgr.replace({ pageUrl: LOGIN_ROUTE })
  }

  build() {
    Stack() {
      Image($r('app.media.quec_app_welcome_page'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .height('100%')
  }
}