import axios, { AxiosError, AxiosHeaders, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { describe, expect, it } from '@ohos/hypium'
import { QuecHttpLog } from '../main/ets/interceptor/QuecHttpLog'
import { QuecRequestLogInterceptor } from '../main/ets/interceptor/QuecRequestLogInterceptor'
import { QuecResponseLogInterceptor } from '../main/ets/interceptor/QuecResponseLogInterceptor'

export default function quecHttpLogInterceptorTest(): void {
  describe('QuecHttpLogInterceptor', () => {
    it('prints complete request and response details with one request id', 0, () => {
      const lines: string[] = []
      const log: QuecHttpLog = new QuecHttpLog((tag: string, message: string, isError: boolean) => {
        lines.push(message)
      })
      const headers: AxiosHeaders = new AxiosHeaders()
      headers.set('Authorization', 'Bearer test-token')
      const config: InternalAxiosRequestConfig = {
        baseURL: 'https://example.com', method: 'post', url: '/items', params: { page: 2 },
        data: { pwd: 'test-password' }, headers
      }
      const requestInterceptor: QuecRequestLogInterceptor = new QuecRequestLogInterceptor(
        axios.create({ baseURL: 'https://example.com' }), log
      )
      const responseInterceptor: QuecResponseLogInterceptor = new QuecResponseLogInterceptor(log)
      const sent: InternalAxiosRequestConfig = requestInterceptor.handler(config)
      expect(lines.length).assertEqual(0)
      const response: AxiosResponse = {
        data: { code: 200, msg: '', data: { id: 7 } }, status: 200, statusText: 'OK',
        headers: { 'Content-Type': 'application/json' }, config
      }
      const received: AxiosResponse = responseInterceptor.handler(response)
      const output: string = lines.join('\n')

      expect(sent === config).assertTrue()
      expect(received === response).assertTrue()
      expect(output.indexOf('[1] ┌────── Request') >= 0).assertTrue()
      expect(output.indexOf('[1] │ POST https://example.com/items?page=2') >= 0).assertTrue()
      expect(output.indexOf('Bearer test-token') >= 0).assertTrue()
      expect(output.indexOf('test-password') >= 0).assertTrue()
      const responseStart: number = output.indexOf('[1] ┌────── Response')
      expect(responseStart > output.indexOf('[1] ┌────── Request')).assertTrue()
      expect(output.indexOf('[1] │ POST https://example.com/items?page=2', responseStart) > responseStart).assertTrue()
      expect(output.indexOf('[1] │ HTTP 200') >= 0).assertTrue()
      expect(output.indexOf('"id": 7') >= 0).assertTrue()
    })

    it('prints long bodies without truncating the last chunk', 0, () => {
      const lines: string[] = []
      const log: QuecHttpLog = new QuecHttpLog((tag: string, message: string, isError: boolean) => {
        lines.push(message)
      })
      const body: string = 'x'.repeat(800) + 'END-OF-BODY'
      const config: InternalAxiosRequestConfig = { method: 'post', url: '/long', data: body, headers: new AxiosHeaders() }

      log.request(config, 'https://example.com/long')
      expect(lines.length).assertEqual(0)
      const response: AxiosResponse = {
        data: body + 'RESPONSE-END', status: 200, statusText: 'OK', headers: {}, config
      }
      log.response(response)

      expect(lines.length > 4).assertTrue()
      expect(lines.join('').indexOf('END-OF-BODY') >= 0).assertTrue()
      expect(lines.join('').indexOf('RESPONSE-END') >= 0).assertTrue()
      for (let i: number = 0; i < lines.length; i++) {
        if (lines[i].indexOf('END-OF-BODY') >= 0 || lines[i].indexOf('RESPONSE-END') >= 0) {
          expect(lines[i].startsWith('[1] │ ')).assertTrue()
        }
      }
    })

    it('prints concurrent requests as separate completed blocks', 0, () => {
      const lines: string[] = []
      const tags: string[] = []
      const log: QuecHttpLog = new QuecHttpLog((tag: string, message: string, isError: boolean) => {
        tags.push(tag)
        lines.push(message)
      })
      const first: InternalAxiosRequestConfig = { method: 'get', url: '/first', headers: new AxiosHeaders() }
      const second: InternalAxiosRequestConfig = { method: 'get', url: '/second', headers: new AxiosHeaders() }
      log.request(first, 'https://example.com/first')
      log.request(second, 'https://example.com/second')
      expect(lines.length).assertEqual(0)

      log.response({ data: 'second result', status: 200, statusText: 'OK', headers: {}, config: second })
      const secondBlockLength: number = lines.length
      expect(lines.join('\n').indexOf('[2] │ GET https://example.com/second') >= 0).assertTrue()
      expect(lines.join('\n').indexOf('[2] │ GET https://example.com/second') >= 0).assertTrue()
      expect(lines.join('\n').indexOf('[1]') < 0).assertTrue()

      log.response({ data: 'first result', status: 200, statusText: 'OK', headers: {}, config: first })
      for (let i: number = 0; i < lines.length; i++) {
        expect(lines[i].startsWith(i < secondBlockLength ? '[2]' : '[1]')).assertTrue()
        expect(tags[i]).assertEqual('QuecHttpLog')
      }
    })

    it('keeps request and response outcomes when the log writer fails', 0, async () => {
      const log: QuecHttpLog = new QuecHttpLog((tag: string, message: string, isError: boolean) => {
        throw new Error('log writer failed')
      })
      const config: InternalAxiosRequestConfig = { method: 'get', url: '/items', headers: new AxiosHeaders() }
      const requestInterceptor: QuecRequestLogInterceptor = new QuecRequestLogInterceptor(axios.create(), log)
      const responseInterceptor: QuecResponseLogInterceptor = new QuecResponseLogInterceptor(log)
      const response: AxiosResponse = { data: { code: 200 }, status: 200, statusText: 'OK', headers: {}, config }
      const error: AxiosError = new AxiosError<Object>('offline', 'ERR_NETWORK', config)

      expect(requestInterceptor.handler(config) === config).assertTrue()
      expect(responseInterceptor.handler(response) === response).assertTrue()
      let caught: Error | undefined
      try {
        await responseInterceptor.onError(error)
      } catch (reason) {
        caught = reason as Error
      }
      expect(caught === error).assertTrue()
    })

    it('prints HTTP errors and preserves the original rejection', 0, async () => {
      const lines: string[] = []
      const log: QuecHttpLog = new QuecHttpLog((tag: string, message: string, isError: boolean) => {
        lines.push(message)
      })
      const config: InternalAxiosRequestConfig = { method: 'get', url: '/failed', headers: new AxiosHeaders() }
      log.request(config, 'https://example.com/failed')
      const response: AxiosResponse = {
        data: { code: 5032, msg: 'expired' }, status: 401, statusText: 'Unauthorized', headers: {}, config
      }
      const error: AxiosError = new AxiosError('Request failed', 'ERR_BAD_RESPONSE', config, undefined, response)
      const interceptor: QuecResponseLogInterceptor = new QuecResponseLogInterceptor(log)
      let caught: Error | undefined
      try {
        await interceptor.onError(error)
      } catch (reason) {
        caught = reason as Error
      }

      const output: string = lines.join('\n')
      expect(caught === error).assertTrue()
      expect(output.indexOf('[1] ┌────── Response Error') >= 0).assertTrue()
      expect(output.indexOf('[1] │ GET https://example.com/failed') >= 0).assertTrue()
      expect(output.indexOf('[1] │ HTTP 401') >= 0).assertTrue()
      expect(output.indexOf('"code": 5032') >= 0).assertTrue()
      expect(output.indexOf('Request failed') >= 0).assertTrue()
    })

    it('prints network errors without a response', 0, async () => {
      const lines: string[] = []
      const log: QuecHttpLog = new QuecHttpLog((tag: string, message: string, isError: boolean) => {
        lines.push(message)
      })
      const config: InternalAxiosRequestConfig = { method: 'get', url: '/offline', headers: new AxiosHeaders() }
      log.request(config, 'https://example.com/offline')
      const error: AxiosError = new AxiosError<Object>('Network Error', 'ERR_NETWORK', config)
      const interceptor: QuecResponseLogInterceptor = new QuecResponseLogInterceptor(log)
      let caught: Error | undefined
      try {
        await interceptor.onError(error)
      } catch (reason) {
        caught = reason as Error
      }

      const output: string = lines.join('\n')
      expect(caught === error).assertTrue()
      expect(output.indexOf('[1] ┌────── Response Error') >= 0).assertTrue()
      expect(output.indexOf('[1] │ GET https://example.com/offline') >= 0).assertTrue()
      expect(output.indexOf('[1] │ ERROR') >= 0).assertTrue()
      expect(output.indexOf('ERR_NETWORK') >= 0).assertTrue()
      expect(output.indexOf('Network Error') >= 0).assertTrue()
    })
  })
}
