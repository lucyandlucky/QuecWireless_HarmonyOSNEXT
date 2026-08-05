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

      Divider()
        .width('100%')
        .margin({ top: 10 })
        .color(this.focused ? $r('app.color.W3') : '#E7E7E7')
        .strokeWidth(1)

    }.width('100%')
  }
}