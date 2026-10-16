import { QuecOemBusinessConfigModel } from '../model/QuecOemBusinessConfigModel';
import { QuecOemRawReader as R, QuecRawObject } from './QuecOemRawReader';

/** 解析底部 Tab 和个人中心基础菜单所需的业务字段。 */
export class QuecOemBusinessConfigParser {
  public static parse(raw: QuecRawObject | undefined): QuecOemBusinessConfigModel {
    const model: QuecOemBusinessConfigModel = new QuecOemBusinessConfigModel()
    model.appTab = R.string(raw, 'appTab', model.appTab)
    model.userCenterConfig = R.string(raw, 'userCenterConfig', model.userCenterConfig)
    model.isHomeList = R.boolean(raw, 'isHomeList', model.isHomeList)
    model.isShowDeviceManager = R.boolean(raw, 'isShowDeviceManager', model.isShowDeviceManager)
    model.isShowMessageCenter = R.boolean(raw, 'isShowMessageCenter', model.isShowMessageCenter)
    model.isShowFeedback = R.boolean(raw, 'isShowFeedback', model.isShowFeedback)
    model.quecFeedbackPanel = R.number(raw, 'quecFeedbackPanel', model.quecFeedbackPanel)
    return model
  }
}
