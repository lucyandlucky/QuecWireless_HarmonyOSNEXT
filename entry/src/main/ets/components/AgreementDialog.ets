@CustomDialog
export struct AgreementDialog {
  controller?: CustomDialogController
  onAgree = () => {
  }
  onCancel = () => {
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.quec_important_tip'))
          .fontColor($r('app.color.W1'))
          .fontSize($r('app.float.T7_F'))
          .fontWeight(FontWeight.Bold)
        Text($r('app.string.quec_warning_content1', $r('app.string.app_name')))
          .margin({ top: '15vp' })
          .fontColor($r('app.color.W2'))
          .fontSize($r('app.float.T4_F'))
          .lineHeight('')
      }
      .padding({ left: '16vp', right: '16vp' })
    }
    .padding({ top: '25vp' })
  }
}
