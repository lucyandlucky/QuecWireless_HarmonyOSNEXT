import { QuecUserCenterSubModel } from '@quec/oem-app-config'

import { QuecPersonalCenterResources } from '../utils/QuecPersonalCenterResources'

@ComponentV2
export struct PersonalCenterMenuItem {
  @Param item: QuecUserCenterSubModel = new QuecUserCenterSubModel()
  @Event onItemClick: (item: QuecUserCenterSubModel) => void = () => {
  }

  build() {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 16 }) {
        Row({ space: 12 }) {
          Image(QuecPersonalCenterResources.icon(this.item.identifier))
            .width(20)
            .height(20)
          Text(QuecPersonalCenterResources.title(this.item.title))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .lineHeight(24)
            .fontColor($r('app.color.W1'))
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        Image($r('app.media.quec_personal_center_right_arrow'))
          .width(16)
          .height(16)
      }
      .width('100%')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
    .onClick(() => this.onItemClick(this.item))
  }
}
