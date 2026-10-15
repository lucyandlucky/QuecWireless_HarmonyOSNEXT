export interface QuecDeviceModel {
  productKey?: string | null
  deviceKey?: string | null
  deviceName?: string | null
  productName?: string | null
  logoImage?: string | null
  productIcon?: string | null
  /** 云端在线状态；本地通道状态由后续通道能力补充。 */
  onlineStatus?: number | null
  status?: number | null
  deviceStatus?: string | null
  deviceType?: number | null
  capabilitiesBitmask?: number | null
  verified?: string | null
  accessType?: string | null
  networkType?: string | null
  protocol?: string | null
  shareCode?: string | null
  /** 根据 shareCode 计算。 */
  isShared?: boolean | null
  bindMode?: number | null
  isNative?: number | null
  upgradeStatus?: number | null
  userConfirmStatus?: number | null
  lowPowerProduct?: boolean | null
  lowPowerStatus?: boolean | null
  deviceBindTimeTs?: number | null
  lastOfflineTimeTs?: number | null
}
