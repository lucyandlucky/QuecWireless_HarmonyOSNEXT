import { QuecDeviceModel } from '@quec/device-sdk'

import { DeviceListUiState } from '../state/DeviceListUiState'
import { DeviceListViewModel } from '../viewmodel/DeviceListViewModel'
import { DeviceCard } from './DeviceCard'

@ComponentV2
export struct DeviceList {
  private viewModel: DeviceListViewModel = new DeviceListViewModel()
  private scroller: Scroller = new Scroller()
  @Local private state: DeviceListUiState = this.viewModel.state

  aboutToAppear(): void {
    this.viewModel.init()
  }

  aboutToDisappear(): void {
    this.viewModel.dispose()
  }

  @Builder
  EmptyContent() {
    Column({ space: 12 }) {
      if (this.state.loading) {
        LoadingProgress()
          .width(28)
          .height(28)
          .color($r('app.color.M0'))
        Text($r('app.string.Loading'))
          .fontSize(14)
          .fontColor($r('app.color.W3'))
      } else {
        Image($r('app.media.quec_device_list_empty'))
          .width(240)
          .height(140)
          .objectFit(ImageFit.Contain)
        Text($r('app.string.quec_device_not_yet'))
          .fontSize(14)
          .fontColor($r('app.color.W3'))
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ bottom: 64 })
  }

  @Builder
  PaginationFooter() {
    Row({ space: 8 }) {
      if (this.state.loadingMore) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color($r('app.color.W3'))
        Text($r('app.string.quec_refresh_footer_refreshing'))
          .fontSize(12)
          .fontColor($r('app.color.W3'))
      } else if (!this.state.hasNextPage) {
        Text($r('app.string.quec_refresh_footer_noMoreData'))
          .fontSize(12)
          .fontColor($r('app.color.W3'))
      }
    }
    .width('100%')
    .height(40)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.quec_home_device_devicelist_title'))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.W1'))
      }
      .width('100%')
      .height(40)
      .padding({ left: 16, right: 16 })

      Refresh({ refreshing: this.state.refreshing }) {
        if (this.state.devices.length > 0) {
          Grid(this.scroller, {
            regularSize: [1, 1],
            irregularIndexes: [this.state.devices.length]
          }) {
            ForEach(this.state.devices, (device: QuecDeviceModel) => {
              GridItem() {
                DeviceCard({ device: device })
              }
            }, (device: QuecDeviceModel, index: number) => DeviceListViewModel.deviceKey(device) || `device-${index}`)
            GridItem() {
              this.PaginationFooter()
            }
          }
          .width('100%')
          .height('100%')
          .columnsTemplate('1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .cachedCount(2)
          .padding({ top: 8, left: 12, right: 12, bottom: 12 })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .onReachEnd(() => this.viewModel.loadMore())
        } else {
          List() {
            ListItem() {
              this.EmptyContent()
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
      }
      .layoutWeight(1)
      .width('100%')
      .onRefreshing(() => this.viewModel.refresh())
    }
    .width('100%')
    .height('100%')
  }
}
