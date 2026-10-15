import { QuecDeviceListParamsModel, QuecDeviceModel, QuecDeviceService } from '@quec/device-sdk'

import { DeviceListUiState } from '../state/DeviceListUiState'

const PAGE_SIZE: number = 20

export class DeviceListViewModel {
  readonly state: DeviceListUiState = new DeviceListUiState()
  private initialized: boolean = false
  private hasLoaded: boolean = false
  private pageNumber: number = 0
  private requestVersion: number = 0

  public init(): void {
    if (this.initialized) {
      return
    }
    this.initialized = true
    this.refresh()
  }

  public dispose(): void {
    // 组件销毁后忽略尚未返回的请求。
    this.requestVersion++
    this.initialized = false
    this.state.loading = false
    this.state.refreshing = false
    this.state.loadingMore = false
  }

  public async refresh(): Promise<void> {
    if (this.state.loading || this.state.refreshing) {
      return
    }
    // 刷新可以替代正在进行的分页请求，旧分页结果不得再追加。
    const version = ++this.requestVersion
    this.state.loading = !this.hasLoaded
    this.state.refreshing = this.hasLoaded
    this.state.loadingMore = false
    try {
      const response = await QuecDeviceService.getDeviceList(this.createParams(1))
      if (version !== this.requestVersion) {
        return
      }
      this.state.deviceList = this.mergeDevices([], response.data.list)
      this.pageNumber = response.data.pageNum
      this.state.hasNextPage = response.data.hasNextPage && response.data.list.length > 0
      this.hasLoaded = true
    } catch (_) {
      return
    } finally {
      if (version === this.requestVersion) {
        this.state.loading = false
        this.state.refreshing = false
      }
    }
  }

  public async loadMore(): Promise<void> {
    if (this.state.loading || this.state.refreshing || this.state.loadingMore || !this.state.hasNextPage) {
      return
    }
    const version = ++this.requestVersion
    this.state.loadingMore = true
    try {
      const response = await QuecDeviceService.getDeviceList(this.createParams(this.pageNumber + 1))
      if (version !== this.requestVersion) {
        return
      }
      this.state.deviceList = this.mergeDevices(this.state.deviceList, response.data.list)
      this.pageNumber = response.data.pageNum
      this.state.hasNextPage = response.data.hasNextPage && response.data.list.length > 0
    } catch (_) {
      return
    } finally {
      if (version === this.requestVersion) {
        this.state.loadingMore = false
      }
    }
  }

  private createParams(page: number): QuecDeviceListParamsModel {
    const params = new QuecDeviceListParamsModel()
    params.page = page
    params.pageSize = PAGE_SIZE
    return params
  }

  private mergeDevices(previous: QuecDeviceModel[], incoming: QuecDeviceModel[]): QuecDeviceModel[] {
    const devices: QuecDeviceModel[] = []
    const indexes = new Map<string, number>()
    for (const device of previous.concat(incoming)) {
      const key = DeviceListViewModel.deviceKey(device)
      const index = indexes.get(key)
      if (key.length > 0 && index !== undefined) {
        devices[index] = device
      } else {
        if (key.length > 0) {
          indexes.set(key, devices.length)
        }
        devices.push(device)
      }
    }
    return devices
  }

  public static deviceKey(device: QuecDeviceModel): string {
    const pk = device.productKey ?? ''
    const dk = device.deviceKey ?? ''
    return pk.length > 0 && dk.length > 0 ? `${pk.length}:${pk}${dk.length}:${dk}` : ''
  }
}
