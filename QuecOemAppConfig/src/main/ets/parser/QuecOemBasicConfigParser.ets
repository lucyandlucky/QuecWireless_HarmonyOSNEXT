import { QuecOemAppName, QuecOemBasicConfigModel } from '../model/QuecOemBasicConfigModel';
import { QuecOemRawReader as R, QuecRawObject } from './QuecOemRawReader';

export class QuecOemBasicConfigParser {
  private static appName(raw: QuecRawObject | undefined): QuecOemAppName {
    const model: QuecOemAppName = new QuecOemAppName()
    model.cn = R.string(raw, 'cn', model.cn)
    model.en = R.string(raw, 'en', model.en)
    return model
  }

  public static parse(raw: QuecRawObject | undefined): QuecOemBasicConfigModel {
    const model: QuecOemBasicConfigModel = new QuecOemBasicConfigModel()
    model.bundleId = R.string(raw, 'bundleId', model.bundleId)
    model.appVersion = R.string(raw, 'appVersion', model.appVersion)
    model.appVersionCode = R.string(raw, 'appVersionCode', model.appVersionCode)
    const appName: QuecRawObject | undefined = R.object(raw, 'appName')
    if (appName !== undefined) {
      model.appName = QuecOemBasicConfigParser.appName(appName)
    }
    model.area = R.string(raw, 'area', model.area)
    model.appTypeId = R.number(raw, 'appTypeId', model.appTypeId)
    return model
  }
}
