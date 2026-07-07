@Entry
@ComponentV2
struct Welcome {
  build() {
    // Column()
    //   .width('100%')
    //   .height('100%')
    //   .backgroundImage($r('app.media.app_startup'))
    //   .backgroundImageSize(ImageSize.Cover)
    //   .backgroundImagePosition(Alignment.Center)
    Stack() {
      Image($r('app.media.app_startup'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .height('100%')
  }
}