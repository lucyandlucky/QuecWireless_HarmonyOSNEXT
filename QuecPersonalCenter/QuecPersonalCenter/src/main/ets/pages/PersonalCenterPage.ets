import { HMRouterMgr } from '@hadss/hmrouter'
import { getWindowInsetsState, WindowInsetsState } from '@quec/basic-ui'
import { LOGIN_ROUTE } from '@quec/login-api'
import { QuecUserCenterId, QuecUserCenterMainModel, QuecUserCenterSubModel } from '@quec/oem-app-config'

import { PersonalCenterHeader } from '../components/PersonalCenterHeader'
import { PersonalCenterMenuItem } from '../components/PersonalCenterMenuItem'
import { PersonalCenterUiState } from '../state/PersonalCenterUiState'
import { PersonalCenterViewModel } from '../viewmodel/PersonalCenterViewModel'

@ComponentV2
export struct PersonalCenterPage {
  @Local private windowInsets: WindowInsetsState = getWindowInsetsState()
  private viewModel: PersonalCenterViewModel = new PersonalCenterViewModel()
  @Local private state: PersonalCenterUiState = this.viewModel.state

  aboutToAppear(): void {
    this.viewModel.init()
  }

  aboutToDisappear(): void {
    this.viewModel.dispose()
  }

  private showPlaceholder(message: string): void {
    this.getUIContext().getPromptAction().showToast({ message })
  }

  private onMenuClick(item: QuecUserCenterSubModel): void {
    if (item.identifier === QuecUserCenterId.DEVICE) {
      this.showPlaceholder('设备管理暂未实现')
    } else if (item.identifier === QuecUserCenterId.MESSAGE) {
      this.showPlaceholder('消息中心暂未实现')
    } else if (item.identifier === QuecUserCenterId.SETTING) {
      this.showPlaceholder('设置暂未实现')
    } else if (item.identifier === QuecUserCenterId.ABOUT) {
      this.showPlaceholder('关于我们暂未实现')
    } else if (item.identifier === QuecUserCenterId.HELP) {
      if (item.panelId > 0) {
        this.showPlaceholder('帮助面板暂未实现')
      } else {
        this.showPlaceholder('帮助文档暂未实现')
      }
    } else if (item.identifier === QuecUserCenterId.FEEDBACK) {
      if (item.panelId > 0) {
        this.showPlaceholder('反馈面板暂未实现')
      } else {
        this.showPlaceholder('意见反馈暂未实现')
      }
    }
  }

  private async logout(): Promise<void> {
    if (this.state.isLoggingOut || this.state.loadingUser) {
      return
    }
    try {
      await this.viewModel.logout()
      HMRouterMgr.replace({ pageUrl: LOGIN_ROUTE })
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({
        message: (error as Error).message
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.quec_personal_center_top_bg'))
        .width('100%')
        .aspectRatio(375 / 188)
        .objectFit(ImageFit.Fill)

      List({ space: 12 }) {
        ListItem() {
          PersonalCenterHeader({
            user: this.state.user,
            onHeadClick: () => this.showPlaceholder('个人资料暂未实现')
          })
        }
        .padding({ top: 48, bottom: 20 })
        ForEach(this.viewModel.menuGroups, (group: QuecUserCenterMainModel) => {
          ListItemGroup() {
            ForEach(group.configs, (item: QuecUserCenterSubModel) => {
              ListItem() {
                PersonalCenterMenuItem({
                  item: item,
                  onItemClick: (clicked: QuecUserCenterSubModel) => this.onMenuClick(clicked)
                })
              }
            }, (item: QuecUserCenterSubModel) => item.identifier)
          }
          .backgroundColor($r('app.color.B2'))
          .borderRadius(12)
          .clip(true)
        }, (group: QuecUserCenterMainModel) => group.identifier)
        ListItem() {
          Button($r('app.string.quec_user_signout'))
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.W1'))
            .backgroundColor($r('app.color.B2'))
            .borderRadius(12)
            .enabled(!this.state.isLoggingOut && !this.state.loadingUser)
            .onClick(() => this.logout())
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12 })
      .contentStartOffset(this.windowInsets.top)
      .contentEndOffset(16)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.B1'))
  }
}
