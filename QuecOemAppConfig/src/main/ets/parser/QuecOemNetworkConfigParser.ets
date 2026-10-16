import { QuecOemNetwork, QuecOemNetworkConfigModel } from '../model/QuecOemNetworkConfigModel';
import { QuecOemRawReader as R, QuecRawObject } from './QuecOemRawReader';

export class QuecOemNetworkConfigParser {
  private static networkConfig(raw: QuecRawObject | undefined): QuecOemNetworkConfigModel {
    const model: QuecOemNetworkConfigModel = new QuecOemNetworkConfigModel()
    model.environment = R.string(raw, 'environment', model.environment)
    model.baseUrl = R.string(raw, 'baseUrl', model.baseUrl)
    model.webSocketUrl = R.string(raw, 'webSocketUrl', model.webSocketUrl)
    model.webSocketV2Url = R.string(raw, 'webSocketV2Url', model.webSocketV2Url)
    model.saasUrl = R.string(raw, 'saasUrl', model.saasUrl)
    model.userDomain = R.string(raw, 'userDomain', model.userDomain)
    model.userDomainSecret = R.string(raw, 'userDomainSecret', model.userDomainSecret)
    model.ssid = R.string(raw, 'ssid', model.ssid)
    model.resetPswStid = R.string(raw, 'resetPswStid', model.resetPswStid)
    model.loginStid = R.string(raw, 'loginStid', model.loginStid)
    model.registerStid = R.string(raw, 'registerStid', model.registerStid)
    model.cancelStid = R.string(raw, 'cancelStid', model.cancelStid)
    model.eaid = R.string(raw, 'eaid', model.eaid)
    model.resetPswEtid = R.string(raw, 'resetPswEtid', model.resetPswEtid)
    model.registerEtid = R.string(raw, 'registerEtid', model.registerEtid)
    model.cancelEtid = R.string(raw, 'cancelEtid', model.cancelEtid)
    model.bootstrapUrl = R.string(raw, 'bootstrapUrl', model.bootstrapUrl)
    model.bootstrapPath = R.string(raw, 'bootstrapPath', model.bootstrapPath)
    model.bootstrapToken = R.string(raw, 'bootstrapToken', model.bootstrapToken)
    return model
  }

  public static parse(raw: QuecRawObject | undefined): QuecOemNetwork {
    const model: QuecOemNetwork = new QuecOemNetwork()
    model.china = QuecOemNetworkConfigParser.networkConfig(R.object(raw, 'china'))
    model.europe = QuecOemNetworkConfigParser.networkConfig(R.object(raw, 'europe'))
    model.northAmerica = QuecOemNetworkConfigParser.networkConfig(R.object(raw, 'northAmerica'))
    return model
  }
}
