import { QuecTabRegistry } from './QuecTabRegistry';

/**
 * 按 tabKey 取出页面组件并渲染。
 *
 * 单独一层是为了让查表只发生一次（在 aboutToAppear），而不是每次 build 都查一遍、
 * 查不到还重复打日志。MainTabModel 不持有 WrappedBuilder，所以这个解析必须在 UI 层做。
 */
@ComponentV2
export struct TabContentHost {
  @Param tabKey: string = ''
  @Local private page: WrappedBuilder<[]> | undefined = undefined

  aboutToAppear(): void {
    this.page = QuecTabRegistry.page(this.tabKey)
  }

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
