import { LOGIN_ROUTE } from '@quec/login-api';
import { MAIN_ROUTE, WELCOME_ROUTE } from '@quec/main-api';
import { QuecAgreementStorage } from '@quec/main';
import { AttributeUpdater, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { HMNavigation, HMNavigationOption } from '@hadss/hmrouter';
import { getWindowInsetsState, WindowInsetsState } from '@quec/basic-ui';
import { QuecUserService } from '@quec/user-sdk';

const DOMAIN = 0x0000;
const APP_NAVIGATION_ID: string = 'QuecAppNavigation'

class AppNavigationModifier extends AttributeUpdater<NavigationAttribute> {
  initializeModifier(instance: NavigationAttribute): void {
    instance.mode(NavigationMode.Stack)
  }
}

function createNavigationOptions(): HMNavigationOption {
  const options = new HMNavigationOption()
  options.modifier = new AppNavigationModifier()
  return options
}

function resolveRootUrl(): string {
  if (!QuecAgreementStorage.hasAgreed()) {
    return WELCOME_ROUTE
  }
  return QuecUserService.isLogin() ? MAIN_ROUTE : LOGIN_ROUTE
}

@Entry
@ComponentV2
struct AppRoot {
  private rootUrl: string = resolveRootUrl()
  private navigationOptions: HMNavigationOption = createNavigationOptions()
  private windowInsets: WindowInsetsState = getWindowInsetsState()

  private async updateWindowInsets(): Promise<void> {
    try {
      const uiContext = this.getUIContext()
      const context = uiContext.getHostContext()
      if (!context) {
        return
      }
      const windowClass = await window.getLastWindow(context)
      const systemArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      const navigationArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      this.windowInsets.top = uiContext.px2vp(systemArea.topRect.height)
      this.windowInsets.bottom = uiContext.px2vp(navigationArea.bottomRect.height)
    } catch (error) {
      const businessError = error as BusinessError
      hilog.error(
        DOMAIN,
        'WindowInsets',
        'Failed to update window insets. code: %{public}d, message: %{public}s',
        businessError.code,
        businessError.message
      )
    }
  }

  build() {
    Stack() {
      Image($r('app.media.quec_app_welcome_page'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      HMNavigation({
        navigationId: APP_NAVIGATION_ID,
        homePageUrl: this.rootUrl,
        options: this.navigationOptions
      })
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      this.updateWindowInsets()
    })
  }
}
