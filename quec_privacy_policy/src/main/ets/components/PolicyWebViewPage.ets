import webview from '@ohos.web.webview'
import { QuecTitleBar } from 'quec_basic_ui'
import { PolicyRouteParams, PolicySource } from '../model/PolicyRoute'
import { PolicyUiState } from '../state/PolicyUiState'
import { PolicyViewModel } from '../viewmodel/PolicyViewModel'

@Builder
export function PolicyWebViewPageBuilder(
  _name: string,
  param: Object
) {
  PolicyWebViewPage({
    params: param as PolicyRouteParams
  })
}

@ComponentV2
export struct PolicyWebViewPage {
  @Consumer('AppNavigation') navigation: NavPathStack = new NavPathStack()
  private controller: webview.WebviewController = new webview.WebviewController()
  @Param params: PolicyRouteParams = {
    source: PolicySource.DIRECT_URL,
    url: '',
    title: ''
  }
  private viewModel: PolicyViewModel = new PolicyViewModel()
  @Local state: PolicyUiState = this.viewModel.state

  private handleBack(): boolean {
    try {
      if (this.controller.accessBackward()) {
        this.controller.backward()
        return true
      }
      this.navigation.pop()
      return true
    } catch (error) {
      console.error(`Policy back failed: ${JSON.stringify(error)}`)
      return false
    }
  }

  aboutToAppear(): void {
    this.viewModel.initialize(this.params)
  }

  onBackPress(): boolean {
    return this.handleBack()
  }

  build() {
    NavDestination() {
      Column() {
        QuecTitleBar({
          title: this.state.title,
          onBack: () => this.handleBack()
        })

        Stack({ alignContent: Alignment.Center }) {
          if (this.state.htmlUrl.length > 0) {
            Web({
              src: this.state.htmlUrl,
              controller: this.controller
            })
              .width('100%')
              .height('100%')
              .visibility(this.state.webError ? Visibility.Hidden : Visibility.Visible)
              .javaScriptAccess(true)
              .domStorageAccess(true)
              .onPageBegin(() => {
                this.viewModel.onWebLoadStart()

              })
              .onPageEnd(() => {
                this.viewModel.onWebLoadingFinish()

              })
              .onErrorReceive((event) => {
                if (event.request.isMainFrame()) {
                  const requestUrl = event.request.getRequestUrl()
                  const errorInfo = event.error.getErrorInfo()
                  console.error(`Policy page load failed: ${requestUrl}, ${errorInfo}`)
                  this.viewModel.onWebLoadError()
                }
              })
          }
          if ((this.state.apiLoading || this.state.webLoading)
            && (!this.state.apiError && !this.state.webError)) {
            LoadingProgress()
              .width(32)
              .height(32)
          }
          if (this.state.apiError) {
            Column({ space: 12 }) {
              Text($r('app.string.quec_policy_load_error'))
                .textAlign(TextAlign.Center)
              Button($r('app.string.quec_policy_retry')).onClick(() => {
                this.viewModel.retryLatest()
              })
            }
          } else if (this.state.webError) {
            Column({ space: 12 }) {
              Text(this.state.htmlUrl.length > 0
                ? $r('app.string.quec_policy_load_error')
                : $r('app.string.quec_policy_invalid_link'))
              if (this.state.htmlUrl.length > 0) {
                Button($r('app.string.quec_policy_retry'))
                  .onClick(() => {
                    this.viewModel.preparedRetry()
                    this.controller.refresh()
                  })
              }
            }.alignItems(HorizontalAlign.Center)
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }
}
