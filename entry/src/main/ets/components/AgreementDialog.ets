@CustomDialog
export struct AgreementDialog {
  controller?: CustomDialogController
  onAgree = () => {
  }
  onCancel = () => {
  }

  build() {
    Column() {
      Text($r('app.string.quec_important_tip'))
      Text($r('app.string.quec_warning_content1', $r('app.string.app_name')))
    }
  }
}
