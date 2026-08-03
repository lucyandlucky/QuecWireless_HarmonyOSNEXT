export class QuecNetworkConstants {
  static readonly DEFAULT_CONNECT_TIMEOUT_MS: number = 20 * 1000
  static readonly DEFAULT_READ_TIMEOUT_MS: number = 20 * 1000
  static readonly BUSINESS_SUCCESS_CODE: number = 200
  static readonly TOKEN_INVALID_CODE: number = 5032
  static readonly TOKEN_MISSING_CODE: number = 5106
  static readonly DEFAULT_SUB_CODE: number = -1
  static readonly HEADER_APP_ID: string = 'appId'
  static readonly HEADER_APP_VERSION: string = 'appVersion'
  static readonly HEADER_APP_SYSTEM_TYPE: string = 'appSystemType'
  static readonly HEADER_AUTHORIZATION: string = 'Authorization'
  static readonly HEADER_LANGUAGE: string = 'X-Q-Language'
  static readonly HEADER_RANDOM_URL: string = 'quec-random-url'
  static readonly HEADER_APP_INFO: string = 'app-info'
  static readonly HEADER_CONTENT_TYPE: string = 'Content-Type'
  static readonly CONTENT_TYPE_JSON: string = 'application/json; charset=utf-8'
  static readonly LANGUAGE_CN: string = 'CN'
  static readonly LANGUAGE_EN: string = 'EN'
  static readonly LANGUAGE_HANT: string = 'zh-Hant'
}
