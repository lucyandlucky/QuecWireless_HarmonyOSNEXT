import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { getWindowInsetsState, QuecTitleBar, WindowInsetsState } from '@quec/basic-ui'
import { LOGIN_ROUTE } from '@quec/login-api'
import { PERSONAL_CENTER_SETTINGS_ROUTE } from '@quec/personal-center-api'

import { PersonalCenterSettingsRow } from '../components/PersonalCenterSettingsRow'
import { getPersonalCenterRouteState } from '../navigation/PersonalCenterRouteParams'
import { PersonalCenterUiState } from '../state/PersonalCenterUiState'
import { PersonalCenterSettingsViewModel } from '../viewmodel/PersonalCenterSettingsViewModel'

@HMRouter({ pageUrl: PERSONAL_CENTER_SETTINGS_ROUTE })
@ComponentV2
export struct PersonalCenterSettingsPage {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  @Local private state: PersonalCenterUiState = getPersonalCenterRouteState()
  private viewModel: PersonalCenterSettingsViewModel = new PersonalCenterSettingsViewModel(this.state)

  private showPlaceholder(): void {
    this.getUIContext().getPromptAction().showToast({ message: '功能暂未实现' })
  }

  private async logout(): Promise<void> {
    try {
      if (!await this.viewModel.logout()) {
        return
      }
      // 保留当前页面再替换为登录页，移除底下的已登录页面。
      const stack: NavPathStack | null = HMRouterMgr.getCurrentPathStack()
      if (stack !== null && stack.size() > 1) {
        const indexes: number[] = []
        for (let index: number = 0; index < stack.size() - 1; index++) {
          indexes.push(index)
        }
        stack.removeByIndexes(indexes)
      }
      HMRouterMgr.replace({ pageUrl: LOGIN_ROUTE, animator: false })
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({ message: (error as Error).message })
    }
  }

  @Builder
  SectionTitle(title: ResourceStr) {
    Text(title)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .lineHeight(17)
      .fontColor($r('app.color.W2'))
      .width('100%')
      .height(37)
      .padding({ left: 20, right: 4, top: 12, bottom: 8 })
  }

  @Builder
  SectionDivider() {
    Divider()
      .strokeWidth(0.5)
      .color($r('app.color.quec_personal_center_divider'))
      .margin({ left: 20, right: 20 })
  }

  build() {
    Column() {
      QuecTitleBar({
        title: $r('app.string.quec_custom_key_setting'),
        onBack: () => HMRouterMgr.pop()
      })
      Scroll() {
        Column({ space: 8 }) {
          Column() {
            this.SectionTitle($r('app.string.quec_safety'))
            PersonalCenterSettingsRow({
              title: $r('app.string.quec_account_and_security'),
              onItemClick: () => this.showPlaceholder()
            })
            this.SectionDivider()
          }
          Column() {
            this.SectionTitle($r('app.string.quec_ota_update'))
            PersonalCenterSettingsRow({
              title: $r('app.string.quec_ota_device'), badge: '9',
              onItemClick: () => this.showPlaceholder()
            })
            this.SectionDivider()
          }
          Column() {
            this.SectionTitle($r('app.string.quec_general'))
            Row() {
              Column({ space: 4 }) {
                Text($r('app.string.quec_family_pattern'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .lineHeight(22)
                  .fontColor($r('app.color.W1'))
                Text($r('app.string.quec_user_setting_family_mode'))
                  .fontSize(12)
                  .lineHeight(17)
                  .fontColor($r('app.color.W3'))
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Image($r('app.media.quec_personal_center_switch_off'))
                .width(44)
                .height(24)
            }
            .width('100%')
            .constraintSize({ minHeight: 75 })
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .onClick(() => this.showPlaceholder())
            PersonalCenterSettingsRow({
              title: $r('app.string.quec_user_push'),
              onItemClick: () => this.showPlaceholder()
            })
            PersonalCenterSettingsRow({
              title: $r('app.string.quec_display_dark'), darkModeArrow: true,
              onItemClick: () => this.showPlaceholder()
            })
            PersonalCenterSettingsRow({
              title: $r('app.string.quec_setting_cache'), value: '2.56MB', showArrow: false,
              onItemClick: () => this.showPlaceholder()
            })
            this.SectionDivider()
          }
          Column() {
            this.SectionTitle($r('app.string.quec_private'))
            PersonalCenterSettingsRow({
              title: $r('app.string.quec_setting_privacy'),
              onItemClick: () => this.showPlaceholder()
            })
            PersonalCenterSettingsRow({
              title: $r('app.string.quec_setting_permission'),
              onItemClick: () => this.showPlaceholder()
            })
          }
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      Column() {
        Button($r('app.string.quec_user_signout'))
          .width('100%')
          .height(52)
          .borderRadius(52)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.quec_personal_center_error'))
          .backgroundColor($r('app.color.B3'))
          .enabled(!this.state.isLoggingOut && !this.state.loadingUser)
          .onClick(() => this.logout())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: Math.max(24, this.windowInsets.bottom) })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B2'))
  }
}
