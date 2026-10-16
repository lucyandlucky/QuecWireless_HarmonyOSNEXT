import { QuecDialogContent } from '@quec/basic-ui';
import { PolicyType } from '@quec/privacy-policy-api';
import { QuecLoginPolicy } from './QuecLoginPolicy';

export interface LoginPolicyDialogData {
  onCancel: () => void
  onConfirm: () => void
  onOpenPolicy: (type: PolicyType, title: ResourceStr) => void
}

@Builder
export function buildLoginPolicyDialog(content: QuecDialogContent<LoginPolicyDialogData>) {
  QuecLoginPolicyConfirmDialog({
    onCancel: content.data.onCancel,
    onConfirm: content.data.onConfirm,
    onOpenPolicy: content.data.onOpenPolicy
  })
}

@ComponentV2
struct QuecLoginPolicyConfirmDialog {
  @Event onCancel: () => void = () => {
  }
  @Event onConfirm: () => void = () => {
  }
  @Event onOpenPolicy: (type: PolicyType, title: ResourceStr) => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.quec_login_privacy_info_title'))
        .width('100%')
        .fontSize(16)
        .lineHeight(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.W1'))
        .textAlign(TextAlign.Center)

      QuecLoginPolicy({
        checkedIconVisible: false,
        textAlign: TextAlign.Center,
        onOpenPolicy: this.onOpenPolicy
      })
        .constraintSize({ minHeight: 40 })
        .margin({ top: 16 })

      Row({ space: 12 }) {
        Button($r('app.string.quec_cancel'))
          .width(99)
          .height(52)
          .borderRadius(26)
          .fontSize(16)
          .fontColor($r('app.color.W2'))
          .backgroundColor($r('app.color.B1'))
          .onClick(() => {
            this.onCancel()
          })

        Button($r('app.string.quec_login_privacy_info_confirm'))
          .layoutWeight(1)
          .height(52)
          .borderRadius(26)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.M1'))
          .onClick(() => {
            this.onConfirm()
          })
      }
      .width('100%')
      .margin({ top: 32 })
    }
    .width('100%')
    .padding({ top: 28, left: 20, right: 20, bottom: 24 })
  }
}
