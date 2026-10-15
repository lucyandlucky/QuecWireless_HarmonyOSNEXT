import { QuecOemAppTab, QuecOemBusinessConfigModel } from '../model/QuecOemBusinessConfigModel';
import { QuecOemBasicConfigModel } from '../model/QuecOemBasicConfigModel';
import { QuecOemNetwork } from '../model/QuecOemNetworkConfigModel';
import { QuecUserCenterConfigModel } from '../model/QuecUserCenterConfigModel';

/**
 * Android DefaultConfig 中的顶层默认值
 */
export class QuecOemDefaultConfig {
  static readonly CONFIG_ID: number = 111
  static readonly VERSION: string = '1.0.0'
  static readonly PLATFORM: string = 'android'
}

/**
 * App 配置，由 QuecOemConfigManager 解析配置文件后写入。
 * 解析前（或配置缺失时）各字段为 Android DefaultConfig 的默认值。
 */
export class QuecOemAppConfig {
  /** 配置文件 ID，由配置平台生成 */
  static configId: number = QuecOemDefaultConfig.CONFIG_ID
  /** 配置文件版本，由配置平台生成 */
  static version: string = QuecOemDefaultConfig.VERSION
  /** 应用平台，由配置平台生成 */
  static platform: string = QuecOemDefaultConfig.PLATFORM
  static basic: QuecOemBasicConfigModel = new QuecOemBasicConfigModel()
  static network: QuecOemNetwork = new QuecOemNetwork()
  static business: QuecOemBusinessConfigModel = new QuecOemBusinessConfigModel()
  static userCenter: QuecUserCenterConfigModel = new QuecUserCenterConfigModel()
  /** 底部 tab，由顶层 appTabBarConfig 或 business.appTab 派生 */
  static appTab: QuecOemAppTab = new QuecOemAppTab()
}
