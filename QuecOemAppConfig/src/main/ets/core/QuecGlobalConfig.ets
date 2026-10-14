import { QLog } from '@quec/log';
import { QuecMmkvManager } from '@quec/mmkv';

import { QuecOemBasicConfigModel } from '../model/QuecOemBasicConfigModel';
import { QuecOemNetworkConfigModel } from '../model/QuecOemNetworkConfigModel';
import { QuecRegion } from '../model/QuecRegion';
import { QuecOemAppConfig } from './QuecOemAppConfig';

const TAG: string = 'QuecGlobalConfig'
/** 与 Android CommonConstant.SERVICE_TYPE 同名，便于两边代码用同一个词检索 */
const KEY_SERVICE_TYPE: string = 'service_type'
const AREA_CHINA: string = 'china'
const AREA_EUROPE: string = 'europe'

/**
 * 当前生效的配置，业务代码的统一入口。
 *
 * `QuecOemAppConfig` 与配置文件严格一一对应（network 下三个区域并列），
 * 这里只负责挑出当前区域那一份，并转发与区域无关的部分。
 *
 * 注意：这不是 Android `GlobalConfig` 的移植。全部成员都是 getter，读穿到
 * `QuecOemAppConfig`，不保存任何配置副本。不要往这里加可变字段，也不要加
 * `getBaseXxxUrl()` 那类地址拼接方法——前者会让配置出现两份真相，
 * 后者由 axios 的 baseURL 承担。
 */
export class QuecGlobalConfig {
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
   * 区域选择，纯函数。判断顺序与 Android QuectelApplication.setNetConfig() 一致，不可调整：
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
   * 与 Android 一样，每次启动都回写 service_type。
   */
  public static init(): void {
    const area: string = QuecOemAppConfig.basic.area
    if (area.length === 0) {
      // 配置解析失败时会走到这里。保留 Android 的行为（落到北美），但留下排查线索。
      QLog.w(TAG, 'basic.area is empty, the configuration may not have been parsed')
    }
    QuecGlobalConfig.currentRegion = QuecGlobalConfig.resolve(area, QuecGlobalConfig.readSaved())
    QuecGlobalConfig.persist(QuecGlobalConfig.currentRegion)
    QLog.i(TAG, `region: ${QuecGlobalConfig.currentRegion}, area: ${area}`)
  }

  public static get region(): QuecRegion {
    return QuecGlobalConfig.currentRegion
  }

  /**
   * 当前区域的网络配置。每次读穿到 QuecOemAppConfig，
   * 所以配置重新解析（会新建对象）之后不会拿到旧引用。
   */
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

  // 以下与区域无关，直接转发。thirdPlatform 和 business 的解析还没补，
  // 补解析时在这里一并加 getter，避免现在读到空默认值。
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
}
