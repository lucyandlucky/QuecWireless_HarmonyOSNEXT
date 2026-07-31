import { QuecBackIcon } from '../drawable/QuecBackIcon'
import { getWindowInsetsState, WindowInsetsState } from '../state/WindowInsetState'

@ComponentV2
export struct QuecTitleBar {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()

  build() {
    Column() {
      Row() {
        Stack() {
          QuecBackIcon()
        }
        .alignContent(Alignment.Center)
        .onClick(() => {

        })

        Text('Title')
          .layoutWeight(1)
          .fontColor($r('app.color.W1'))
          .fontSize('16fp')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)

        Text('right')
      }
      .padding({
        left: 16,
        right: 16,
        top: 10,
        bottom: 10
      })
    }
    .padding({
      top: this.windowInsets.top
    })
    .backgroundColor($r('app.color.B2'))
  }
}