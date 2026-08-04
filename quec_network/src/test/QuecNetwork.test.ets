import { describe, expect, it } from '@ohos/hypium'
import { QuecNetworkConfig } from '../main/ets/config/QuecNetworkConfig'
import { QuecNetworkConstants } from '../main/ets/constants/QuecNetworkConstants'
import { QuecHttpClient } from '../main/ets/core/QuecHttpClient'
import { QuecNetwork } from '../main/ets/core/QuecNetwork'
import { QuecNetworkError, QuecNetworkErrorType } from '../main/ets/error/QuecNetworkError'

function createConfig(baseUrl: string = 'https://example.com'): QuecNetworkConfig {
  return {
    baseUrl: baseUrl,
    appId: '271',
    appVersion: '1.0.0',
    appSystemType: 'harmony',
    languageProvider: () => 'CN',
    appInfoProvider: () => '[model][brand][device][api]'
  }
}

export default function quecNetworkTest(): void {
  describe('QuecNetwork', () => {
    it('should reject access before initialization', 0, () => {
      let thrown: boolean = false

      try {
        QuecNetwork.getClient()
      } catch (error) {
        thrown = true
        const networkError: QuecNetworkError = error as QuecNetworkError
        expect(networkError.type).assertEqual(QuecNetworkErrorType.REQUEST_ILLEGAL)
        expect(networkError.code).assertEqual(QuecNetworkConstants.UNKNOWN_ERROR_CODE)
        expect(networkError.message).assertEqual('QuecNetwork must be initialized before use')
      }

      expect(thrown).assertTrue()
    })

    it('should initialize and return the shared client', 0, () => {
      QuecNetwork.initialize(createConfig())

      expect(QuecNetwork.isInitialized()).assertTrue()
      expect(QuecNetwork.getClient() instanceof QuecHttpClient).assertTrue()
    })

    it('should replace the client when initialized again', 0, () => {
      const firstClient: QuecHttpClient = QuecNetwork.getClient()

      QuecNetwork.initialize(createConfig('https://second.example.com'))
      const secondClient: QuecHttpClient = QuecNetwork.getClient()

      expect(firstClient === secondClient).assertFalse()
    })
  })
}
