import { HMRouterMgr } from '@hadss/hmrouter'
import { getWindowInsetsState, WindowInsetsState } from '@quec/basic-ui'
import { QuecUserCenterId, QuecUserCenterMainModel, QuecUserCenterSubModel } from '@quec/oem-app-config'
import { PERSONAL_CENTER_PROFILE_ROUTE, PERSONAL_CENTER_SETTINGS_ROUTE } from '@quec/personal-center-api'

import { PersonalCenterHeader } from '../components/PersonalCenterHeader'
import { PersonalCenterMenuItem } from '../components/PersonalCenterMenuItem'
import { PersonalCenterRouteParams } from '../navigation/PersonalCenterRouteParams'
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
      HMRouterMgr.push({
        pageUrl: PERSONAL_CENTER_SETTINGS_ROUTE,
        param: new PersonalCenterRouteParams(this.state)
      })
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
            onHeadClick: () => HMRouterMgr.push({
              pageUrl: PERSONAL_CENTER_PROFILE_ROUTE,
              param: new PersonalCenterRouteParams(this.state)
            })
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
