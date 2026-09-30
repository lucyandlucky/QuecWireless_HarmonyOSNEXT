import { resourceManager } from '@kit.LocalizationKit'
import { util } from '@kit.ArkTS'
import { parse } from 'yaml'
import { QuecAppConfigData } from '../model/QuecAppConfigData'

export class QuecOemAppConfig {
  private static config?: QuecAppConfigData

  public static initialize(manager: resourceManager.ResourceManager): void {
    QuecOemAppConfig.config = undefined
    let bytes: Uint8Array
    try {
      bytes = manager.getRawFileContentSync('config/app_config.yml')
    } catch (error) {
      throw new Error('Cannot read config/app_config.yml from application resources')
    }
    const source: string = util.TextDecoder.create('utf-8').decodeToString(bytes)
    QuecOemAppConfig.config = parse(source) as QuecAppConfigData
  }

  public static get(): QuecAppConfigData {
    const config: QuecAppConfigData | undefined = QuecOemAppConfig.config
    if (config === undefined) {
      throw new Error('QuecOemAppConfig.initialize must be called before use')
    }
    return config
  }
}
