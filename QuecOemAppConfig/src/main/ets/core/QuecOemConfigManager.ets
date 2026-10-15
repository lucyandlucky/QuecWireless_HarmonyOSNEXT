import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { parse } from 'yaml';
import { QLog } from '@quec/log';

import { QuecOemModelParser } from '../parser/QuecOemModelParser';
import { QuecOemRawReader as R, QuecRawObject, QuecRawValue } from '../parser/QuecOemRawReader';
import { QuecOemAppConfig, QuecOemDefaultConfig } from './QuecOemAppConfig';

const TAG: string = 'QuecOemConfigManager'
const APP_CONFIG_PATH: string = 'config/app_config.yml'


/**
 * App 配置文件管理类，对应 Android com.quectel.oem.config.QuecOemConfigManager。
 * 当前只解析顶层字段、basic 和 network。
 */
export class QuecOemConfigManager {
  private static describe(error: Object | null | undefined): string {
    return error instanceof Error ? error.message : String(error)
  }

  /**
   * 解析 rawfile 中的明文配置文件，对应 Android parseAssetConfigFile。失败时只记录日志，不抛出异常。
   */
  public static init(context: common.Context): void {
    QLog.d(TAG, `init, path = ${APP_CONFIG_PATH}`)
    try {
      const bytes: Uint8Array = context.resourceManager.getRawFileContentSync(APP_CONFIG_PATH)
      QuecOemConfigManager.parseConfigContent(util.TextDecoder.create('utf-8').decodeToString(bytes))
    } catch (error) {
      QLog.e(TAG, `parseRawFileConfig failed: ${QuecOemConfigManager.describe(error)}`)
    }
  }

  /**
   * 解析 YAML 文本并写入 QuecOemAppConfig。YAML 无效时抛出异常，当前配置保持不变。
   */
  public static parseConfigContent(source: string): void {
    const raw: QuecRawObject | undefined = R.asObject(parse(source) as QuecRawValue)
    if (raw === undefined) {
      throw new Error('Configuration content is not a YAML mapping')
    }
    QuecOemAppConfig.configId = R.number(raw, 'configId', QuecOemDefaultConfig.CONFIG_ID)
    QuecOemAppConfig.version = R.string(raw, 'version', QuecOemDefaultConfig.VERSION)
    QuecOemAppConfig.platform = R.string(raw, 'platform', QuecOemDefaultConfig.PLATFORM)
    // A missing section falls back to the model defaults, like Android DefaultConfig.
    QuecOemAppConfig.basic = QuecOemModelParser.basic(R.object(raw, 'basic'))
    QuecOemAppConfig.network = QuecOemModelParser.network(R.object(raw, 'network'))
    QuecOemAppConfig.appTab = QuecOemModelParser.appTab(
      R.objectArray(raw, 'appTabBarConfig'),
      R.string(R.object(raw, 'business'), 'appTab', '')
    )
    if (QuecOemAppConfig.appTab.tabs.length === 0) {
      // 没有 tab 配置 App 就没有主页面，必须暴露出来，不用硬编码默认值掩盖。
      QLog.e(TAG, 'appTab is empty: both appTabBarConfig and business.appTab are missing or invalid')
    }
  }
}
