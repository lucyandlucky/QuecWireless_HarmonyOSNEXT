import { QuecUserModel } from '@quec/user-sdk'

import { PersonalCenterAvatar } from './PersonalCenterAvatar'

@ComponentV2
export struct PersonalCenterHeader {
  @Param user: QuecUserModel | undefined = undefined
  @Event onHeadClick: () => void = () => {
  }

  build() {
    Row({ space: 12 }) {
      PersonalCenterAvatar({ user: this.user })
      Column({ space: 4 }) {
        Text(this.user?.nikeName ?? '')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .lineHeight(22)
          .fontColor($r('app.color.W1'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text($r('app.string.quec_user_remind'))
          .fontSize(12)
          .lineHeight(17)
          .fontColor($r('app.color.W3'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(64)
    .padding({ left: 8, right: 8 })
    .onClick(() => this.onHeadClick())
    .accessibilityGroup(true)
  }
}
