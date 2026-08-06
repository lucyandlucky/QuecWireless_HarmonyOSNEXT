import { PolicyType } from 'quec_privacy_policy'

@Extend(Span)
function policyText() {
  .fontColor($r('app.color.M0'))
}

@Extend(Text)
function dialogActionText(color: ResourceColor) {
  .layoutWeight(1)
  .height('100%')
  .fontColor(color)
  .fontSize('16fp')
  .textAlign(TextAlign.Center)
}


@ComponentV2
export struct AgreementDialog {
  @Event onAgree: () => void = () => {
  }
  @Event onCancel: () => void = () => {
  }
  @Event onOpenPolicy: (type: PolicyType, title: ResourceStr) => void = (_type: PolicyType, _title: ResourceStr) => {
  }
  @Event navigationWebView: () => void = () => {
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.quec_important_tip'))
          .fontColor($r('app.color.W1'))
          .fontSize($r('app.float.T7_F'))
          .fontWeight(FontWeight.Bold)
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
        .margin({ top: '15vp' })
        .fontColor($r('app.color.W2'))
        .fontSize($r('app.float.T4_F'))
        .lineHeight($r('app.float.T4_H'))

        .wordBreak(WordBreak.BREAK_ALL)
      }
      .padding({
        top: '25vp',
        bottom: '15vp',
        left: '16vp',
        right: '16vp'
      })

      Divider()
        .color($r('app.color.W6'))
        .strokeWidth(0.7)

      Row() {
        Text($r('app.string.quec_disagree'))
          .dialogActionText($r('app.color.W3'))
          .onClick(this.onCancel)

        Divider()
          .color($r('app.color.W6'))
          .strokeWidth(0.7)
          .vertical(true)

        Text($r('app.string.quec_agree'))
          .dialogActionText($r('app.color.M0'))
          .onClick(this.onAgree)
      }
      .width('100%')
      .height('56fp')
    }
  }
}
