enum AppStage {
  LOADING,
  WELCOME,
  LOGIN,
  MAIN
}

@Entry
@ComponentV2
struct AppRoot {
  @Provider('AppNavigation')
  private pathStack: NavPathStack = new NavPathStack()
  private hasInitialized: boolean = false

  private resetToRoute(routeName: string) {
    const rootPage = new NavPathInfo(
      routeName,
      undefined,
      undefined,
      true
    )
    this.pathStack.setPathStack([rootPage], false)
  }

  private initializeApp() {
    if (this.hasInitialized) {
      return
    }
    this.hasInitialized = true
    const hasAgreePolicy: boolean = false

    if (!hasAgreePolicy) {
      this.resetToRoute('QuecWelcomePage')
    }

  }

  build() {
    Navigation(this.pathStack) {
      Stack() {
        Image($r('app.media.quec_app_welcome_page'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }

      // if (this.stage === AppStage.LOADING) {
      //   Stack() {
      //     Image($r('app.media.quec_app_welcome_page'))
      //       .width('100%')
      //       .height('100%')
      //       .objectFit(ImageFit.Cover)
      //   }
      // } else if (this.stage === AppStage.WELCOME) {
      //   WelcomePage()
      // } else if (this.stage === AppStage.LOGIN) {
      //   Text('login')
      // } else if (this.stage === AppStage.MAIN) {
      //   Text('main')
      // }
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .onAppear(() => {
      this.initializeApp()
    })
  }
}
