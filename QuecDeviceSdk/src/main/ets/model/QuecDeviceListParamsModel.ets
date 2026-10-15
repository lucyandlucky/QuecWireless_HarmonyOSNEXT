import { QuecRequestParams } from '@quec/network-v2'

export class QuecDeviceListParamsModel implements QuecRequestParams {
  page: number = 1
  pageSize: number = 10
  isAssociation: boolean = false
  secondItemCode?: string | null
  /** 产品 Key 列表，多个值使用逗号分隔。 */
  pkList?: string | null
  deviceName?: string | null
}
