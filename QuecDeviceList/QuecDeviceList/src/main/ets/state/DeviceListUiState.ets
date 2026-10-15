import { QuecDeviceModel } from '@quec/device-sdk'

@ObservedV2
export class DeviceListUiState {
  @Trace deviceList: QuecDeviceModel[] = []
  @Trace loading: boolean = false
  @Trace refreshing: boolean = false
  @Trace loadingMore: boolean = false
  @Trace hasNextPage: boolean = false
}
