export const DEVICE_LIST_SERVICE: string = 'quec.device_list'

/** 设备列表对外提供可嵌入的组件构建器。 */
export interface QuecDeviceListService {
  getDeviceListBuilder(): WrappedBuilder<[]>
}
