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

  }
}
