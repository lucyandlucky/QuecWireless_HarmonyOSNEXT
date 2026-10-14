@ComponentV2
export struct QuecBackIcon {
  @Param color: ResourceColor = $r('app.color.W1')

  private getPathCommands(): string {
    const uiContext = this.getUIContext()

    return `M${uiContext.vp2px(7)},${uiContext.vp2px(18)}` +
      `L${uiContext.vp2px(1)},${uiContext.vp2px(12)}` +
      `L${uiContext.vp2px(7)},${uiContext.vp2px(6)}`
  }

  build() {
    Path({
      width: 24,
      height: 24,
      commands: this.getPathCommands()
    })
      .fill(Color.Transparent)
      .stroke(this.color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
      .strokeLineJoin(LineJoinStyle.Round)
  }
}