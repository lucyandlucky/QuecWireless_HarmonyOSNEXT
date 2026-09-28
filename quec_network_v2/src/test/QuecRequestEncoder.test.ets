import { http } from '@kit.NetworkKit'
import { describe, expect, it } from '@ohos/hypium'
import { QuecRequestEncoder } from '../main/ets/adapter/QuecRequestEncoder'
import { QuecNetworkError, QuecNetworkErrorType } from '../main/ets/error/QuecNetworkError'
import {
  QuecBodyFormat,
  QuecFormBody,
  QuecHeaders,
  QuecQueryParams,
  QuecRequestMethod,
  QuecResponseType
} from '../main/ets/model/QuecHttpTypes'
import { QuecRequestConfig } from '../main/ets/model/QuecRequestConfig'

class ItemBody {
  name: string = 'lamp'
}

class DeleteBody {
  id: number = 1
}

export default function quecRequestEncoderTest(): void {
  const encoder: QuecRequestEncoder = new QuecRequestEncoder()

  describe('QuecRequestEncoder', () => {
    it('encodes repeated query values', 0, () => {
      const params: QuecQueryParams = {}
      params.tag = ['a b', 'c&d']
      params.enabled = true
      expect(encoder.encodeQueryParams(params)).assertEqual('tag=a%20b&tag=c%26d&enabled=true')
    })

    it('encodes form fields into the request body', 0, () => {
      const body: QuecFormBody = {}
      body.email = 'a@b.com'
      body.pwd = 'x y'
      const config: QuecRequestConfig = {
        method: QuecRequestMethod.POST,
        url: 'https://example.com/login',
        body,
        bodyFormat: QuecBodyFormat.FORM
      }
      const options: http.HttpRequestOptions = encoder.encodeOptions(config)
      const headers: QuecHeaders = options.header as QuecHeaders

      expect(options.extraData as string).assertEqual('email=a%40b.com&pwd=x%20y')
      expect(headers['Content-Type']).assertEqual('application/x-www-form-urlencoded; charset=utf-8')
    })

    it('uses JSON for object bodies and keeps an explicit content type', 0, () => {
      const requestHeaders: QuecHeaders = {}
      requestHeaders['content-type'] = 'application/vnd.quec+json'
      const config: QuecRequestConfig = {
        method: QuecRequestMethod.POST,
        url: 'https://example.com/items',
        body: new ItemBody(),
        headers: requestHeaders
      }
      const options: http.HttpRequestOptions = encoder.encodeOptions(config)
      const headers: QuecHeaders = options.header as QuecHeaders

      expect(options.extraData as string).assertEqual('{"name":"lamp"}')
      expect(headers['content-type']).assertEqual('application/vnd.quec+json')
      expect(Object.keys(headers).length).assertEqual(1)
    })

    it('allows a DELETE body and rejects a GET body', 0, () => {
      const deleteConfig: QuecRequestConfig = {
        method: QuecRequestMethod.DELETE,
        url: 'https://example.com/items',
        body: new DeleteBody()
      }
      const deletion: http.HttpRequestOptions = encoder.encodeOptions(deleteConfig)
      expect(deletion.extraData as string).assertEqual('{"id":1}')

      let rejected: boolean = false
      try {
        const getConfig: QuecRequestConfig = {
          method: QuecRequestMethod.GET,
          url: 'https://example.com/items',
          body: 'unexpected'
        }
        encoder.encodeOptions(getConfig)
      } catch (error) {
        rejected = true
        expect((error as QuecNetworkError).type).assertEqual(QuecNetworkErrorType.INVALID_CONFIG)
      }
      expect(rejected).assertTrue()
    })

    it('preserves a raw body and requests binary responses', 0, () => {
      const config: QuecRequestConfig = {
        method: QuecRequestMethod.POST,
        url: 'https://example.com/upload',
        body: 'already encoded',
        bodyFormat: QuecBodyFormat.RAW,
        responseType: QuecResponseType.ARRAY_BUFFER
      }
      const options: http.HttpRequestOptions = encoder.encodeOptions(config)
      const headers: QuecHeaders = options.header as QuecHeaders

      expect(options.extraData as string).assertEqual('already encoded')
      expect(headers['Content-Type']).assertEqual('text/plain; charset=utf-8')
      expect(options.expectDataType).assertEqual(http.HttpDataType.ARRAY_BUFFER)
    })
  })
}
