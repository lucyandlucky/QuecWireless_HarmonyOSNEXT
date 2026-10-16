import { common } from '@kit.AbilityKit';
import {
  getWindowInsetsState,
  QuecDialog,
  QuecDialogHandle,
  QuecTitleBar,
  WindowInsetsState
} from '@quec/basic-ui';
import { QuecColorUtils } from '@quec/foundation';
import { HMLifecycleState, HMRouter, HMRouterMgr, IHMLifecycleOwner } from '@hadss/hmrouter';

import { QuecLoginButton } from '../components/QuecLoginButton';
import { QuecLoginPolicy } from '../components/QuecLoginPolicy';
import { QuecUnderlineTextInput } from '../components/QuecUnderlineTextInput';
import { LOGIN_ROUTE } from '@quec/login-api';
import { QuecUserService } from '@quec/user-sdk';
import { MAIN_ROUTE } from '@quec/main-api';
import { PolicyRouteParams, PolicySource, PolicyType, PRIVACY_WEBVIEW_ROUTE } from '@quec/privacy-policy-api';
import { buildLoginPolicyDialog, LoginPolicyDialogData } from '../components/QuecLoginPolicyConfirmDialog';

@HMRouter({ pageUrl: LOGIN_ROUTE })
@ComponentV2
export struct LoginPage {
  private lifecycleOwner: IHMLifecycleOwner | null = null
  private policyDialog: QuecDialogHandle<LoginPolicyDialogData> | null = null
  private isPageVisible: boolean = false
  private pageVersion: number = 0
  private isConfirmingPolicy: boolean = false
  private isOpeningPolicy: boolean = false
  private policyDialogActionPending: boolean = false
  private restorePolicyDialog: boolean = false
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  @Local private isLoggingIn: boolean = false
  @Local private hasAgreedPolicy: boolean = false
  @Local private account: string = ''
  @Local private password: string = ''
  private onPageBackPressed = (): boolean => {
    this.moveAppToBackground()
    return true
  }

  aboutToAppear(): void {
    this.isPageVisible = true
    this.lifecycleOwner = HMRouterMgr.getCurrentLifecycleOwner()
    this.lifecycleOwner?.addObserver(HMLifecycleState.onShown, this.onPageShown)
    this.lifecycleOwner?.addObserver(HMLifecycleState.onHidden, this.onPageHidden)
    this.lifecycleOwner?.addObserver(
      HMLifecycleState.onBackPressed,
      this.onPageBackPressed
    )
  }

  aboutToDisappear(): void {
    this.isPageVisible = false
    this.pageVersion++
    this.restorePolicyDialog = false
    this.lifecycleOwner?.removeObserver(HMLifecycleState.onShown, this.onPageShown)
    this.lifecycleOwner?.removeObserver(HMLifecycleState.onHidden, this.onPageHidden)
    this.lifecycleOwner?.removeObserver(
      HMLifecycleState.onBackPressed,
      this.onPageBackPressed
    )
    this.closePolicyDialog().catch((error: Error) => {
      console.error(`Close login policy dialog failed: ${error.message}`)
    })
    this.lifecycleOwner = null
  }

  private onPageShown = (): void => {
    this.isPageVisible = true
    if (this.restorePolicyDialog && !this.hasAgreedPolicy) {
      this.restorePolicyDialog = false
      this.showPolicyDialog()
    }
  }

  private onPageHidden = (): void => {
    this.isPageVisible = false
    this.pageVersion++
    this.closePolicyDialog().catch((error: Error) => {
      console.error(`Close login policy dialog failed: ${error.message}`)
    })
  }

  @Computed
  get loginVerify(): boolean {
    return this.account.length >= 1 && this.password.length >= 6 && !this.isLoggingIn
  }

  private moveAppToBackground(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    context.moveAbilityToBackground().catch()
  }

  private async onLogin(): Promise<void> {
    if (!this.loginVerify || !this.isPageVisible || this.isConfirmingPolicy) {
      return
    }
    if (!this.hasAgreedPolicy) {
      this.showPolicyDialog()
      return
    }
    await this.login()
  }

  private showPolicyDialog(): void {
    if (this.policyDialog !== null || !this.isPageVisible || this.isLoggingIn || this.hasAgreedPolicy) {
      return
    }
    const data: LoginPolicyDialogData = {
      onCancel: () => {
        this.closePolicyDialog().catch((error: Error) => {
          console.error(`Close login policy dialog failed: ${error.message}`)
        })
      },
      onConfirm: () => {
        this.confirmPolicyAndLogin()
      },
      onOpenPolicy: (type: PolicyType, title: ResourceStr) => {
        this.openPolicy(type, title, true)
      }
    }
    const dialog = QuecDialog.showBottom(
      this.getUIContext(),
      wrapBuilder(buildLoginPolicyDialog),
      data,
      {
        width: '100%',
        cornerRadius: { topLeft: 20, topRight: 20, bottomLeft: 0, bottomRight: 0 },
        closeOnMask: true,
        closeOnBack: true,
        onWillDismiss: (action: DismissDialogAction) => {
          this.policyDialogActionPending = true
          action.dismiss()
        }
      }
    )
    this.policyDialog = dialog
    this.policyDialogActionPending = false
    dialog.closed.then(() => {
      if (this.policyDialog === dialog) {
        this.policyDialog = null
        this.policyDialogActionPending = false
      }
    })
    dialog.ready.catch((error: Error) => {
      console.error(`Open login policy dialog failed: ${error.message}`)
    })
  }

  private closePolicyDialog(): Promise<void> {
    if (this.policyDialog === null) {
      return Promise.resolve()
    }
    this.policyDialogActionPending = true
    return this.policyDialog.close()
  }

  private async confirmPolicyAndLogin(): Promise<void> {
    const dialog = this.policyDialog
    if (dialog === null || this.policyDialogActionPending || this.isConfirmingPolicy ||
      !this.isPageVisible || !this.loginVerify) {
      return
    }
    this.policyDialogActionPending = true
    this.isConfirmingPolicy = true
    this.hasAgreedPolicy = true
    const version = this.pageVersion
    try {
      await dialog.close()
      if (this.isPageVisible && this.pageVersion === version) {
        await this.login()
      }
    } catch (error) {
      console.error(`Confirm login policy failed: ${(error as Error).message}`)
    } finally {
      this.isConfirmingPolicy = false
    }
  }

  private async openPolicy(type: PolicyType, title: ResourceStr, restoreDialog: boolean = false): Promise<void> {
    if (!this.isPageVisible || this.isOpeningPolicy || this.isConfirmingPolicy || this.policyDialogActionPending) {
      return
    }
    this.isOpeningPolicy = true
    this.restorePolicyDialog = restoreDialog
    const version = this.pageVersion
    try {
      await this.closePolicyDialog()
      if (!this.isPageVisible || this.pageVersion !== version) {
        this.restorePolicyDialog = false
        return
      }
      const params: PolicyRouteParams = { source: PolicySource.LATEST, type, title }
      HMRouterMgr.push({ pageUrl: PRIVACY_WEBVIEW_ROUTE, param: params })
    } catch (error) {
      this.restorePolicyDialog = false
      console.error(`Open login policy failed: ${(error as Error).message}`)
    } finally {
      this.isOpeningPolicy = false
    }
  }

  private async login(): Promise<void> {
    if (!this.isPageVisible || !this.loginVerify || !this.hasAgreedPolicy) {
      return
    }
    this.isLoggingIn = true
    const version = this.pageVersion
    try {
      const account: string = this.account.trim()
      if (account.includes('@')) {
        await QuecUserService.loginByEmail(account, this.password)
      } else {
        await QuecUserService.loginByPhone(account, this.password, '86')
      }
      if (this.isPageVisible && this.pageVersion === version) {
        HMRouterMgr.replace({ pageUrl: MAIN_ROUTE })
      }
    } catch (error) {
      if (this.isPageVisible && this.pageVersion === version) {
        this.getUIContext().getPromptAction().showToast({
          message: (error as Error).message
        })
      }
    } finally {
      this.isLoggingIn = false
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
      }
      .width('100%')
      .height(this.windowInsets.top + 180)
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [
          [QuecColorUtils.getColorWithAlpha(0.12, $r('app.color.M1')), 0],
          [QuecColorUtils.getColorWithAlpha(0.02, $r('app.color.B1')), 1]
        ]
      })

      Column() {
        QuecTitleBar({
          transparent: true,
          leftIconVisible: false,
          rightText: {
            text: $r('app.string.quec_login_register'),
            color: $r('app.color.W2'),
            onClick: () => {
            },
          }
        })

        Column() {
          Text($r('app.string.quec_password_login'))
            .fontColor($r('app.color.W1'))
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
          Column({ space: 45 }) {
            QuecUnderlineTextInput({
              value: this.account,
              placeholder: $r('app.string.quec_login_account'),
              onValueChange: (val) => {
                this.account = val
              }
            })
            QuecUnderlineTextInput({
              inputType: InputType.Password,
              value: this.password,
              placeholder: $r('app.string.quec_login_psd'),
              onValueChange: (val) => {
                this.password = val
              }
            })
          }.margin({ top: 52 })

          Text($r('app.string.quec_login_forget'))
            .width('100%')
            .textAlign(TextAlign.RIGHT)
            .fontSize(14)
            .fontColor($r('app.color.W2'))
            .margin({ top: 5 })
            .onClick(() => {
              console.log('ready to navigate forget page')
            })

          QuecLoginPolicy({
            checked: this.hasAgreedPolicy,
            onChecked: (checked) => {
              this.hasAgreedPolicy = checked
            },
            onOpenPolicy: (type: PolicyType, title: ResourceStr) => {
              this.openPolicy(type, title)
            }
          })
            .margin({ top: 16 })

          QuecLoginButton({
            text: $r('app.string.quec_login'),
            verify: this.loginVerify,
            onLogin: () => this.onLogin()
          })

          Text($r('app.string.quec_login_code'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(14)
            .fontColor($r('app.color.W2'))
            .margin({ top: 24 })
        }
        .padding({ top: 12, left: 28, right: 28 })
        .alignItems(HorizontalAlign.Start)

      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B2'))
  }
}
