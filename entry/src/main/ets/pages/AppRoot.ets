import { LOGIN_ROUTE } from 'quec_login';
import { QuecAgreementStorage, WELCOME_ROUTE } from 'quec_main';
import { AttributeUpdater } from '@kit.ArkUI';
import { HMNavigation, HMNavigationOption } from '@hadss/hmrouter';

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

@Entry
@ComponentV2
struct AppRoot {
  private homePageUrl: string = QuecAgreementStorage.hasAgreed()
    ? LOGIN_ROUTE
    : WELCOME_ROUTE
  private navigationOptions: HMNavigationOption = createNavigationOptions()

  build() {
    Stack() {
      Image($r('app.media.quec_app_welcome_page'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      HMNavigation({
        navigationId: APP_NAVIGATION_ID,
        homePageUrl: this.homePageUrl,
        options: this.navigationOptions
      })
    }
    .width('100%')
    .height('100%')
  }
}
