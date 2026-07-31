import { QuecBackIcon } from '../drawable/QuecBackIcon'
import { getWindowInsetsState, WindowInsetsState } from '../state/WindowInsetState'

type Func = () => void

export interface QuecTitleBarRightText {
  text: ResourceStr
  color?: ResourceColor
  onClick: Func
}

export interface QuecTitleBarRightIcon {
  icon: Resource
  onClick: Func
}

@ComponentV2
export struct QuecTitleBar {
  @Param title: ResourceStr = ''
  @Param leftIconVisible: boolean = true
  @Param rightText: QuecTitleBarRightText | null = null
  @Param rightIcons: QuecTitleBarRightIcon[] = []
  @Event onBack: Func = () => {
  }
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  @Local leftWidth: number = 0
  @Local rightWidth: number = 0

  private getTitleInset(): number {
    return Math.max(this.leftWidth, this.rightWidth) + 8
  }

  @Builder
  RightContentBuilder() {
    Row({ space: 8 }) {
      if (this.rightIcons.length > 0) {
        // 图标展示
        ForEach(
          this.rightIcons,
          (item: QuecTitleBarRightIcon) => {
            Stack() {
              Image(item.icon)
                .width(24)
                .height(24)
            }.alignContent(Alignment.Center)
            .onClick(() => item.onClick())
          }
        )
      } else if (this.rightText) {
        // 纯文本展示
        Row() {
          Text(this.rightText.text)
            .fontColor(this.rightText.color ?? $r('app.color.W1'))
            .fontSize('14fp')
            .fontWeight(FontWeight.Medium)
        }
        .onClick(() => this.rightText?.onClick())
        .onAreaChange((_oldValue, newValue) => {
          this.rightWidth = newValue.width as number
        })
      }
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Text(this.title)
          .width('100%')
          .padding({
            left: this.getTitleInset(),
            right: this.getTitleInset()
          })
          .fontColor($r('app.color.W1'))
          .fontSize('16fp')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })

        Row() {
          Row() {
            if (this.leftIconVisible) {
              Stack() {
                QuecBackIcon()
              }
              .alignContent(Alignment.Center)
              .onClick(() => this.onBack())
            }
          }.onSizeChange((_oldValue, newValue) => {
            this.leftWidth = newValue.width as number
          })

          Blank()

          this.RightContentBuilder()
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
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
