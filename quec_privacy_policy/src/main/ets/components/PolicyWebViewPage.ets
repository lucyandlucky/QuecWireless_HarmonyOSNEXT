import webview from '@ohos.web.webview'
import { QuecTitleBar } from 'quec_basic_ui'

@Builder
export function PolicyWebViewPageBuilder(
  name: string,
  param: Object
) {
  PolicyWebViewPage({
    url: (param as Record<string, string>).url
  })
}

@ComponentV2
export struct PolicyWebViewPage {
  private controller: webview.WebviewController = new webview.WebviewController()
  @Param url: string = ""

  onBackPress(): boolean {
    try {
      if (this.controller.accessBackward()) {
        this.controller.backward()
        return true
      }
    } catch (err) {
      console.error(`WebViewPage back failed: ${JSON.stringify(err)}`)
    }
    return false
  }

  build() {
    NavDestination() {
      QuecTitleBar()
      Web({
        src: this.url,
        controller: this.controller
      })
        .width('100%')
        .height('100%')
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onPageBegin(() => {

        })
        .onPageEnd(() => {

        })
        .onErrorReceive(() => {

        })
    }
    .hideTitleBar(true)
  }
}
