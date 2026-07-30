@ComponentV2
export struct QuecBackIcon {
  @Param color: ResourceColor = $r('app.color.W1')

  build() {
    Path({
      width: 24,
      height: 24,
      commands: 'M7 18L1 12L7 6'
    })
      .fill(Color.Transparent)
      .stroke(this.color)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
      .strokeLineJoin(LineJoinStyle.Round)
  }
}