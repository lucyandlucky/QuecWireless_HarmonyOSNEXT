import { curves } from '@kit.ArkUI'

@ComponentV2
export struct QuecUnderlineTextInput {
  @Param value: string = ''
  @Param placeholder: ResourceStr = ''
  @Param inputType: InputType = InputType.Normal
  @Event onValueChange: (value: string) => void
  @Local private focused: boolean = false

  build() {
    Column() {
      TextInput({
        text: this.value,
        placeholder: this.placeholder
      })
        .width('100%')
        .height(32)
        .padding(0)
        .type(this.inputType)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.W1'))
        .placeholderColor($r('app.color.W4'))
        .caretColor($r('app.color.M1'))
        .backgroundColor(Color.Transparent)
        .borderWidth(0)
        .onChange((val: string) => {
          this.onValueChange(val)
        })
        .onFocus(() => {
          this.focused = true
        })
        .onBlur(() => {
          this.focused = false
        })

      Stack({ alignContent: Alignment.Center }) {
        Divider()
          .width('100%')
          .color($r('app.color.quec_login_edit_line_nor'))
          .strokeWidth(1)

        Divider()
          .width('100%')
          .color($r('app.color.quec_login_edit_line_pre'))
          .strokeWidth(1)
          .scale({
            x: this.focused ? 1 : 0,
            y: 1,
            centerX: '50%',
            centerY: '50%'
          })
          .opacity(this.focused ? 1 : 0)
          .animation({
            duration: this.focused ? 280 : 140,
            curve: this.focused
              ? curves.cubicBezierCurve(0.22, 1, 0.36, 1)
              : curves.cubicBezierCurve(0.64, 0, 0.78, 0)
          })
      }
        .width('100%')
        .height(1)
        .margin({ top: 10 })

    }.width('100%')
  }
}
