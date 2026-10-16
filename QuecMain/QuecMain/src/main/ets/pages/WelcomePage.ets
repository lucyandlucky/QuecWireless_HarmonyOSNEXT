import common from '@ohos.app.ability.common'
import { QuecDialog, QuecDialogHandle } from '@quec/basic-ui'
import { PolicyRouteParams, PolicySource, PolicyType, PRIVACY_WEBVIEW_ROUTE } from '@quec/privacy-policy-api'
import { HMLifecycleState, HMRouter, HMRouterMgr, IHMLifecycleOwner } from '@hadss/hmrouter'
import { LOGIN_ROUTE } from '@quec/login-api'
import { WELCOME_ROUTE } from '@quec/main-api'
import { QuecAgreementStorage } from '../storage/QuecAgreementStorage'
import { AgreementDialogData, buildAgreementDialog } from '../components/AgreementDialog'

@HMRouter({ pageUrl: WELCOME_ROUTE })
@ComponentV2
export struct WelcomePage {
  private lifecycleOwner: IHMLifecycleOwner | null = null
  private agreementDialog: QuecDialogHandle<AgreementDialogData> | null = null
  private pageActive: boolean = false
  private pageVisible: boolean = false
  private visibilityVersion: number = 0
  private dialogRequested: boolean = false
  private acceptingAgreement: boolean = false
  private openingPolicy: boolean = false
  private exiting: boolean = false

  aboutToAppear(): void {
    this.pageActive = true
    this.lifecycleOwner = HMRouterMgr.getCurrentLifecycleOwner()
    this.lifecycleOwner?.addObserver(HMLifecycleState.onShown, this.onPageShown)
    this.lifecycleOwner?.addObserver(HMLifecycleState.onHidden, this.onPageHidden)
  }

  aboutToDisappear(): void {
    this.pageActive = false
    this.pageVisible = false
    this.visibilityVersion++
    this.dialogRequested = false
    this.lifecycleOwner?.removeObserver(HMLifecycleState.onShown, this.onPageShown)
    this.lifecycleOwner?.removeObserver(HMLifecycleState.onHidden, this.onPageHidden)
    this.closeAgreementDialog()
    this.lifecycleOwner = null
  }

  private onPageShown = (): void => {
    this.pageVisible = true
    this.visibilityVersion++
    if (QuecAgreementStorage.hasAgreed()) {
      this.enterLogin()
      return
    }
    this.dialogRequested = true
    this.openAgreementDialog()
  }

  private onPageHidden = (): void => {
    this.pageVisible = false
    this.visibilityVersion++
    this.dialogRequested = false
    this.closeAgreementDialog()
  }

  private openAgreementDialog(): void {
    if (!this.pageActive || !this.pageVisible || !this.dialogRequested || this.agreementDialog !== null || this.exiting) {
      return
    }
    const data: AgreementDialogData = {
      onAgree: () => {
        this.acceptAgreement()
      },
      onCancel: () => {
        this.exitApp()
      },
      onBrowseProducts: () => {
        // Product browsing will be implemented separately.
      },
      onOpenPolicy: (type: PolicyType, title: ResourceStr) => {
        this.openPolicy(type, title)
      }
    }
    const dialog = QuecDialog.showCenter(
      this.getUIContext(),
      wrapBuilder(buildAgreementDialog),
      data,
      {
        width: '85%',
        maxWidth: 311,
        maxHeight: '90%',
        cornerRadius: 16,
        backgroundColor: $r('app.color.B2'),
        closeOnMask: false,
        closeOnBack: false,
        onWillDismiss: (action: DismissDialogAction) => {
          if (action.reason === DismissReason.PRESS_BACK && this.dialogRequested) {
            this.exitApp()
          }
        }
      }
    )
    this.agreementDialog = dialog
    dialog.ready.catch((error: Error) => {
      if (this.agreementDialog === dialog) {
        this.dialogRequested = false
      }
      console.error(`Failed to open agreement dialog: ${error.message}`)
    })
    dialog.closed.then(async () => {
      let opened = false
      try {
        await dialog.ready
        opened = true
      } catch (error) {
        // Opening failed; clearing the handle must not request another dialog.
      }
      if (this.agreementDialog === dialog) {
        this.agreementDialog = null
        // A policy page may return before the previous dialog has finished closing.
        if (opened) {
          this.openAgreementDialog()
        }
      }
    })
  }

  private async closeAgreementDialog(): Promise<boolean> {
    const dialog = this.agreementDialog
    if (dialog === null) {
      return true
    }
    try {
      await dialog.close()
      return true
    } catch (error) {
      console.error(`Failed to close agreement dialog: ${JSON.stringify(error)}`)
      return false
    }
  }

  private async acceptAgreement(): Promise<void> {
    if (this.acceptingAgreement || this.openingPolicy || this.exiting || !this.dialogRequested ||
      !this.pageActive || !this.pageVisible) {
      return
    }
    this.acceptingAgreement = true
    const saved = QuecAgreementStorage.setHasAgreed(true)
    if (!saved) {
      this.acceptingAgreement = false
      console.error('Failed to persist the agreement state')
      return
    }
    this.dialogRequested = false
    await this.enterLogin()
    this.acceptingAgreement = false
  }

  private async enterLogin(): Promise<void> {
    const visibilityVersion = this.visibilityVersion
    this.dialogRequested = false
    if (!await this.closeAgreementDialog()) {
      return
    }
    if (this.pageActive && this.pageVisible && visibilityVersion === this.visibilityVersion) {
      HMRouterMgr.replace({ pageUrl: LOGIN_ROUTE })
    }
  }

  private async openPolicy(type: PolicyType, title: ResourceStr): Promise<void> {
    if (this.acceptingAgreement || this.openingPolicy || this.exiting || !this.pageVisible) {
      return
    }
    this.openingPolicy = true
    this.dialogRequested = false
    const visibilityVersion = this.visibilityVersion
    const closed = await this.closeAgreementDialog()
    if (!closed || !this.pageActive || !this.pageVisible || visibilityVersion !== this.visibilityVersion) {
      this.openingPolicy = false
      return
    }
    const params: PolicyRouteParams = {
      source: PolicySource.LATEST,
      type,
      title
    }
    HMRouterMgr.push({ pageUrl: PRIVACY_WEBVIEW_ROUTE, param: params })
    this.openingPolicy = false
  }

  private exitApp(): void {
    if (this.exiting || this.acceptingAgreement || this.openingPolicy || !this.dialogRequested || !this.pageVisible) {
      return
    }
    this.exiting = true
    this.dialogRequested = false
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    context.terminateSelf().catch((error: Error) => {
      this.exiting = false
      this.dialogRequested = true
      this.openAgreementDialog()
      console.error(`terminateSelf failed: ${error.message}`)
    })
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
