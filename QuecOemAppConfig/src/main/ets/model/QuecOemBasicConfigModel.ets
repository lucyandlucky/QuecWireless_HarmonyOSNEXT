/**
 * App 名称
 */
export class QuecOemAppName {
  cn: string = '移联万物'
  en: string = 'QuecOne'
}

/**
 * App 基础配置信息
 */
export class QuecOemBasicConfigModel {
  bundleId: string = ''
  /**
   * App 版本号
   */
  appVersion: string = ''
  appVersionCode: string = ''
  appName: QuecOemAppName = new QuecOemAppName()
  area: string = ''
  appTypeId: number = -1
}
