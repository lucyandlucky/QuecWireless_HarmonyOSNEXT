import { describe, expect, it } from '@ohos/hypium';

import { QuecNetworkConfig } from '../main/ets/config/QuecNetworkConfig';
import { QuecNetworkConstants } from '../main/ets/constants/QuecNetworkConstants';
import { QuecHeaderProvider } from '../main/ets/header/QuecHeaderProvider';
import { QuecHeaders } from '../main/ets/model/QuecRequestOptions';

const uuid: string = '123e4567-e89b-42d3-a456-426614174000'

function createConfig(defaultHeaders?: QuecHeaders): QuecNetworkConfig {
  return {
    baseUrl: 'https://example.com',
    appId: '271',
    appVersion: '1.0.0',
    appSystemType: 'harmony',
    languageProvider: () => 'CN',
    appInfoProvider: () => '[model][brand][device][api]',
    defaultHeaders: defaultHeaders
  }
}

export default function quecHeaderProviderTest(): void {
  describe('QuecHeaderProvider', () => {
    it("should create all public headers", 0, () => {
      const provider = new QuecHeaderProvider(createConfig(), () => uuid)
      const header = provider.createHeaders()

      expect(header[QuecNetworkConstants.HEADER_APP_ID]).assertEqual('271')
      expect(header[QuecNetworkConstants.HEADER_APP_VERSION]).assertEqual('1.0.0')
      expect(header[QuecNetworkConstants.HEADER_APP_SYSTEM_TYPE]).assertEqual('harmony')
      expect(header[QuecNetworkConstants.HEADER_LANGUAGE]).assertEqual('CN')
      expect(header[QuecNetworkConstants.HEADER_APP_INFO]).assertEqual('[model][brand][device][api]')
      expect(header[QuecNetworkConstants.HEADER_RANDOM_URL].length).assertEqual(36)
    })

    it("should apply header priority", 0, () => {
      const defaults: QuecHeaders = {}
      defaults['X-Custom'] = 'global'
      defaults[QuecNetworkConstants.HEADER_APP_VERSION] = 'default-version'
      defaults[QuecNetworkConstants.HEADER_APP_INFO] = 'default-info'

      const requestHeaders: QuecHeaders = {}
      requestHeaders[QuecNetworkConstants.HEADER_APP_ID] = 'request-app'
      requestHeaders[QuecNetworkConstants.HEADER_LANGUAGE] = 'EN'

      const headers = new QuecHeaderProvider(createConfig(defaults)).createHeaders(requestHeaders)

      expect(headers['X-Custom']).assertEqual('global')
      expect(headers[QuecNetworkConstants.HEADER_APP_VERSION]).assertEqual('1.0.0')
      expect(headers[QuecNetworkConstants.HEADER_APP_INFO])
        .assertEqual('[model][brand][device][api]')
      expect(headers[QuecNetworkConstants.HEADER_APP_ID]).assertEqual('request-app')
      expect(headers[QuecNetworkConstants.HEADER_LANGUAGE]).assertEqual('EN')
    })

    it('should refresh dynamic headers for every request', 0, () => {
      let language: string = 'CN'
      const config = createConfig()
      config.languageProvider = () => language
      const provider = new QuecHeaderProvider(config)

      const first = provider.createHeaders()
      language = 'EN'
      const second = provider.createHeaders()

      expect(first[QuecNetworkConstants.HEADER_LANGUAGE]).assertEqual('CN')
      expect(second[QuecNetworkConstants.HEADER_LANGUAGE]).assertEqual('EN')
    })
  })

}