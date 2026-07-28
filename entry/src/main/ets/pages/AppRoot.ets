import { WelcomePage } from 'quec_main';

enum AppStage {
  LOADING,
  WELCOME,
  LOGIN,
  MAIN
}

@Entry
@ComponentV2
struct AppRoot {
  @Local stage: AppStage = AppStage.LOADING
  @Provider('AppNavigation') private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.resolveAppStage()
  }

  private async resolveAppStage(): Promise<void> {
    const hasAgreePolicy: boolean = false
    const hasLogin: boolean = false

    if (!hasAgreePolicy) {
      this.stage = AppStage.WELCOME
    } else if (!hasLogin) {
      this.stage = AppStage.LOGIN
    } else {
      this.stage = AppStage.MAIN
    }
  }

  private switchAppStage(stage: AppStage): void {
    this.pathStack.clear()
    this.stage = stage
  }

  build() {
    Navigation(this.pathStack) {
      if (this.stage === AppStage.LOADING) {
        Stack() {
          Image($r('app.media.quec_app_welcome_page'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        }
      } else if (this.stage === AppStage.WELCOME) {
        WelcomePage()
      } else if (this.stage === AppStage.LOGIN) {
        Text('login')
      } else if (this.stage === AppStage.MAIN) {
        Text('main')
      }
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)

  }
}
