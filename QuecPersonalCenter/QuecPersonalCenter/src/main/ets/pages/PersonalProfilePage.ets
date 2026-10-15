import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { getWindowInsetsState, QuecTitleBar, WindowInsetsState } from '@quec/basic-ui'
import { PERSONAL_CENTER_PROFILE_ROUTE } from '@quec/personal-center-api'

import { PersonalCenterAvatar } from '../components/PersonalCenterAvatar'
import { getPersonalCenterRouteState } from '../navigation/PersonalCenterRouteParams'
import { PersonalCenterUiState } from '../state/PersonalCenterUiState'

@HMRouter({ pageUrl: PERSONAL_CENTER_PROFILE_ROUTE })
@ComponentV2
export struct PersonalProfilePage {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  @Local private state: PersonalCenterUiState = getPersonalCenterRouteState()

  private showPlaceholder(message: string): void {
    this.getUIContext().getPromptAction().showToast({ message })
  }

  @Builder
  ProfileRow(title: ResourceStr, value: string, editable: boolean = false) {
    Row({ space: 16 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .lineHeight(24)
        .fontColor($r('app.color.W1'))
      Row({ space: 4 }) {
        Text(value.length > 0 ? value : '--')
          .fontSize(14)
          .lineHeight(22)
          .fontColor(editable ? $r('app.color.W2') : $r('app.color.W3'))
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        if (editable) {
          Image($r('app.media.quec_personal_center_profile_arrow'))
            .width(16)
            .height(16)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 16 })
    .onClick(() => {
      if (editable) {
        this.showPlaceholder('昵称编辑暂未实现')
      }
    })
  }

  build() {
    Column() {
      QuecTitleBar({
        title: $r('app.string.quec_user_profile'),
        onBack: () => HMRouterMgr.pop()
      })
      Scroll() {
        Column() {
          Column({ space: 8 }) {
            Stack({ alignContent: Alignment.BottomEnd }) {
              PersonalCenterAvatar({ user: this.state.user, avatarSize: 90, avatarBorderWidth: 3 })
              Image($r('app.media.quec_personal_center_avatar_edit'))
                .width(20)
                .height(20)
                .margin({ right: 4, bottom: 4 })
            }
            Text($r('app.string.quec_user_profile_avatar'))
              .fontSize(14)
              .lineHeight(20)
              .fontColor($r('app.color.W2'))
          }
          .width('100%')
          .padding({ top: 28, bottom: 25 })
          .onClick(() => this.showPlaceholder('头像更换暂未实现'))
          Divider()
            .strokeWidth(0.5)
            .color($r('app.color.quec_personal_center_divider'))
            .margin({ left: 20, right: 20 })
          Column() {
            this.ProfileRow($r('app.string.quec_user_nickname'), this.state.user?.nikeName ?? '', true)
            this.ProfileRow($r('app.string.quec_email'), this.state.user?.email ?? '')
            this.ProfileRow($r('app.string.quec_login_phone'), this.state.user?.phone ?? '')
          }
          .padding({ top: 13.5 })
        }
        .width('100%')
        .padding({ bottom: this.windowInsets.bottom + 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B2'))
  }
}
