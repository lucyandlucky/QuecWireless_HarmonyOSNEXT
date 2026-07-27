import webview from '@ohos.web.webview'

// import { webview } from '@kit.ArkWeb'

@Entry
@ComponentV2
struct WebViewPage {
  private controller: webview.WebviewController = new webview.WebviewController()
  @Local url: string = "https://www.baidu.com"

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as Record<string, string>
    if (params?.url) {
      this.url = params.url
    }
  }

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
    Column() {
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
    .width('100%')
    .height('100%')

  }
}
