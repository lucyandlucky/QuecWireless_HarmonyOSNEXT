import { QLog } from '@quec/log';
import { QuecMmkvManager } from '@quec/mmkv';

import { QuecOemAppTab, QuecOemBusinessConfigModel } from '../model/QuecOemBusinessConfigModel';
import { QuecOemBasicConfigModel } from '../model/QuecOemBasicConfigModel';
import { QuecOemNetworkConfigModel } from '../model/QuecOemNetworkConfigModel';
import { QuecRegion } from '../model/QuecRegion';
import { QuecUserCenterConfigModel } from '../model/QuecUserCenterConfigModel';
import { QuecOemAppConfig } from './QuecOemAppConfig';
import { QUEC_TAB_1_NAME, QUEC_TAB_2_NAME, QUEC_TAB_3_NAME } from '../constants/tab';

const TAG: string = 'QuecGlobalConfig'
const KEY_SERVICE_TYPE: string = 'service_type'
const AREA_CHINA: string = 'china'
const AREA_EUROPE: string = 'europe'

/**
 * 当前生效的配置，业务代码的统一入口。
 *
 * `QuecOemAppConfig` 与配置文件严格一一对应（network 下三个区域并列），
 * 这里只负责挑出当前区域那一份，并转发与区域无关的部分。
 *
 */
export class QuecGlobalConfig {
  public static tab1 = 0
  public static tab2 = 1
  public static tab3 = 2
  public static quecTabNames = [QUEC_TAB_1_NAME, QUEC_TAB_2_NAME, QUEC_TAB_3_NAME]
  private static currentRegion: QuecRegion = QuecRegion.CHINA

  private static readSaved(): number {
    // 与 QuecRequestTokenInterceptor 一致：MMKV 未初始化时退回默认值，不抛错。
    if (!QuecMmkvManager.isInitialized()) {
      return QuecRegion.CHINA
    }
    return QuecMmkvManager.getInstance().getInt(KEY_SERVICE_TYPE, QuecRegion.CHINA)
  }

  private static persist(region: QuecRegion): void {
    if (!QuecMmkvManager.isInitialized()) {
      return
    }
    QuecMmkvManager.getInstance().putInt(KEY_SERVICE_TYPE, region)
  }

  /**
   * area 为 china 时固定中国区；否则优先使用已保存的选择（北美先于欧洲）；
   * 没有有效保存值时再按 area 兜底。
   *
   * saved 的默认值是 0（中国），所以非中国区应用首次启动时前两个分支都不命中，
   * 正好落到 area 兜底。
   */
  public static resolve(area: string, saved: number): QuecRegion {
    if (area === AREA_CHINA) {
      return QuecRegion.CHINA
    }
    if (saved === QuecRegion.NORTH_AMERICA) {
      return QuecRegion.NORTH_AMERICA
    }
    if (saved === QuecRegion.EUROPE) {
      return QuecRegion.EUROPE
    }
    return area === AREA_EUROPE ? QuecRegion.EUROPE : QuecRegion.NORTH_AMERICA
  }

  /**
   * 启动时调用，必须在 QuecMmkvManager.init 和 QuecOemConfigManager.init 之后。
   */
  public static init(): void {
    const area: string = QuecOemAppConfig.basic.area
    QuecGlobalConfig.currentRegion = QuecGlobalConfig.resolve(area, QuecGlobalConfig.readSaved())
    QuecGlobalConfig.persist(QuecGlobalConfig.currentRegion)
    QLog.i(TAG, `region: ${QuecGlobalConfig.currentRegion}, area: ${area}`)
  }

  public static get region(): QuecRegion {
    return QuecGlobalConfig.currentRegion
  }

  public static get network(): QuecOemNetworkConfigModel {
    switch (QuecGlobalConfig.currentRegion) {
      case QuecRegion.EUROPE:
        return QuecOemAppConfig.network.europe
      case QuecRegion.NORTH_AMERICA:
        return QuecOemAppConfig.network.northAmerica
      default:
        return QuecOemAppConfig.network.china
    }
  }

  public static get configId(): number {
    return QuecOemAppConfig.configId
  }

  public static get version(): string {
    return QuecOemAppConfig.version
  }

  public static get platform(): string {
    return QuecOemAppConfig.platform
  }

  public static get basic(): QuecOemBasicConfigModel {
    return QuecOemAppConfig.basic
  }

  public static get appTab(): QuecOemAppTab {
    return QuecOemAppConfig.appTab
  }

  public static get business(): QuecOemBusinessConfigModel {
    return QuecOemAppConfig.business
  }

  public static get userCenter(): QuecUserCenterConfigModel {
    return QuecOemAppConfig.userCenter
  }
}
