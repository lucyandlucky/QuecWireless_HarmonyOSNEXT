/**
 * 渲染主页面装配好的 Builder；业务数据模型不持有 UI 构建器。
 */
@ComponentV2
export struct TabContentHost {
  @Param page: WrappedBuilder<[]> | undefined = undefined

  build() {
    Column() {
      if (this.page !== undefined) {
        this.page.builder()
      }
    }
    .width('100%')
    .height('100%')
  }
}
