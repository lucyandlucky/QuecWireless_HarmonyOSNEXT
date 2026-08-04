import { util } from '@kit.ArkTS';
import { QuecNetworkConfig } from '../config/QuecNetworkConfig';
import { QuecNetworkConstants } from '../constants/QuecNetworkConstants';
import { QuecHeaders } from '../model/QuecRequestOptions';

function generateUuid(): string {
  return util.generateRandomUUID()
}

export class QuecHeaderProvider {
  private readonly config: QuecNetworkConfig
  private readonly uuidProvider: () => string

  constructor(
    config: QuecNetworkConfig,
    uuidProvider: () => string = generateUuid) {
    this.config = config
    this.uuidProvider = uuidProvider
  }


  private mergeHeaders(target: QuecHeaders, source?: QuecHeaders): void {
    if (source === undefined) {
      return
    }
    Object.keys(source).forEach((key: string) => {
      target[key] = source[key]
    })
  }

  public createHeaders(requestHeaders?: QuecHeaders): QuecHeaders {
    const headers: QuecHeaders = {}

    this.mergeHeaders(headers, this.config.defaultHeaders)

    // 公共 header
    headers[QuecNetworkConstants.HEADER_APP_ID] = this.config.appId
    headers[QuecNetworkConstants.HEADER_APP_VERSION] = this.config.appVersion
    headers[QuecNetworkConstants.HEADER_APP_SYSTEM_TYPE] = this.config.appSystemType

    // 动态 header
    headers[QuecNetworkConstants.HEADER_RANDOM_URL] = this.uuidProvider()
    headers[QuecNetworkConstants.HEADER_LANGUAGE] = this.config.languageProvider()
    headers[QuecNetworkConstants.HEADER_APP_INFO] = this.config.appInfoProvider()

    this.mergeHeaders(headers, requestHeaders)

    return headers
  }
}