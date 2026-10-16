import window from '@ohos.window'
import { QuecDialogContent } from '@quec/basic-ui'
import { PolicyType } from '@quec/privacy-policy-api'

export class AgreementDialogData {
  onAgree: () => void = () => {}
  onCancel: () => void = () => {}
  onBrowseProducts: () => void = () => {}
  onOpenPolicy: (type: PolicyType, title: ResourceStr) => void = (_type: PolicyType, _title: ResourceStr) => {}
}

@Builder
export function buildAgreementDialog(content: QuecDialogContent<AgreementDialogData>) {
  AgreementDialog({
    onAgree: content.data.onAgree,
    onCancel: content.data.onCancel,
    onBrowseProducts: content.data.onBrowseProducts,
    onOpenPolicy: content.data.onOpenPolicy
  })
}

@Extend(Span)
function policyText() {
  .fontColor($r('app.color.M0'))
  .fontWeight(FontWeight.Medium)
}

@Extend(Button)
function agreementAction(background: ResourceColor, foreground: ResourceColor) {
  .width('100%')
  .height(48)
  .borderRadius(6)
  .backgroundColor(background)
  .fontColor(foreground)
  .fontSize('16fp')
  .fontWeight(600)
}

@ComponentV2
export struct AgreementDialog {
  @Event onAgree: () => void = () => {}
  @Event onCancel: () => void = () => {}
  @Event onBrowseProducts: () => void = () => {}
  @Event onOpenPolicy: (type: PolicyType, title: ResourceStr) => void = (_type: PolicyType, _title: ResourceStr) => {}
  @Local private bodyMaxHeight: number = 280
  private dialogWindow: window.Window | null = null

  aboutToAppear(): void {
    const windowName = this.getUIContext().getWindowName()
    if (windowName === undefined) {
      return
    }
    try {
      this.dialogWindow = window.findWindow(windowName)
      const rect = this.dialogWindow.getWindowProperties().windowRect
      this.updateBodyMaxHeight({ width: rect.width, height: rect.height })
      this.dialogWindow.on('windowSizeChange', this.onWindowSizeChange)
    } catch (error) {
      console.error(`Failed to observe agreement dialog window: ${JSON.stringify(error)}`)
    }
  }

  aboutToDisappear(): void {
    try {
      this.dialogWindow?.off('windowSizeChange', this.onWindowSizeChange)
    } catch (error) {
      console.error(`Failed to remove agreement dialog window observer: ${JSON.stringify(error)}`)
    }
    this.dialogWindow = null
  }

  private onWindowSizeChange = (size: window.Size): void => {
    this.updateBodyMaxHeight(size)
  }

  private updateBodyMaxHeight(size: window.Size): void {
    const uiContext = this.getUIContext()
    let topInset = 0
    let bottomInset = 0
    try {
      const systemArea = this.dialogWindow?.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      const navigationArea = this.dialogWindow?.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      topInset = systemArea === undefined ? 0 : systemArea.topRect.height
      bottomInset = navigationArea === undefined ? 0 : navigationArea.bottomRect.height
    } catch (error) {
      // A resize notification can arrive while the window is being removed.
      return
    }
    const availableHeight = uiContext.px2vp(size.height - topInset - bottomInset) * 0.9
    const titleHeight = uiContext.px2vp(uiContext.fp2px(26))
    // Reserve the heading and three actions; only the policy text scrolls on smaller windows.
    this.bodyMaxHeight = Math.max(48, availableHeight - 24 - titleHeight - 8 - 216)
  }

  build() {
    Column() {
      Column({ space: 8 }) {
        Text($r('app.string.quec_important_tip'))
          .fontColor($r('app.color.W1'))
          .fontSize('18fp')
          .fontWeight(600)
          .lineHeight('26fp')

        Scroll() {
          Text() {
            Span($r('app.string.quec_warning_content1', $r('app.string.app_name')))
            Span($r('app.string.quec_login_user_privacy'))
              .policyText()
              .onClick(() => {
                this.onOpenPolicy(PolicyType.SERVICE, $r('app.string.quec_setting_service_privacy'))
              })
            Span($r('app.string.quec_warning_and'))
            Span($r('app.string.quec_login_privacy'))
              .policyText()
              .onClick(() => {
                this.onOpenPolicy(PolicyType.PRIVACY, $r('app.string.quec_setting_privacy_simple'))
              })
            Span($r('app.string.quec_warning_content2'))
          }
          .width('100%')
          .fontColor($r('app.color.W2'))
          .fontSize('14fp')
          .lineHeight('24fp')
          .wordBreak(WordBreak.BREAK_WORD)
        }
        .width('100%')
        .constraintSize({ maxHeight: this.bodyMaxHeight })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
      }
      .width('100%')
      .padding({ top: 24, left: 24, right: 24 })

      Column({ space: 12 }) {
        Button($r('app.string.quec_agree_and_continue'), { type: ButtonType.Normal })
          .agreementAction($r('app.color.M0'), Color.White)
          .onClick(this.onAgree)

        Button($r('app.string.quec_disagree_and_exit'), { type: ButtonType.Normal })
          .agreementAction($r('app.color.B1'), $r('app.color.W1'))
          .onClick(this.onCancel)

        Button($r('app.string.quec_browse_product_features'), { type: ButtonType.Normal })
          .agreementAction($r('app.color.B1'), $r('app.color.W1'))
          .onClick(this.onBrowseProducts)
      }
      .width('100%')
      .padding(24)
    }
    .width('100%')
  }
}
