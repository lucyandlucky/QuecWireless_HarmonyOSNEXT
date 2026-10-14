import { LOGIN_ROUTE } from '@quec/login-api';
import { MAIN_DEMO_ROUTE, WELCOME_ROUTE } from '@quec/main-api';
import { QuecAgreementStorage } from '@quec/main';
import { AttributeUpdater } from '@kit.ArkUI';
import { HMNavigation, HMNavigationOption } from '@hadss/hmrouter';
import { QuecUserService } from '@quec/user-sdk';

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
  return QuecUserService.isLogin() ? MAIN_DEMO_ROUTE : LOGIN_ROUTE
}

@Entry
@ComponentV2
struct AppRoot {
  private rootUrl: string = resolveRootUrl()
  private navigationOptions: HMNavigationOption = createNavigationOptions()

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
  }
}
