import { http } from '@kit.NetworkKit'
import {
  JSBundleProvider,
  JSBundleProviderError,
  MetroJSBundleProvider,
  MetroJSBundleProviderError
} from '@rnoh/react-native-openharmony'

import {
  concatMetroChunks,
  QuecMetroBuildProgress,
  QuecMetroBundleResult,
  QuecMetroMultipartReader
} from './QuecMetroMultipartReader'

export class QuecMetroJSBundleProvider extends MetroJSBundleProvider {
  private onMessage: (message: string) => void
  private lastMessage: string = ''

  constructor(bundleUrl: string, appKeys: string[], onMessage: (message: string) => void) {
    super(bundleUrl, appKeys)
    this.onMessage = onMessage
  }

  public async getBundle(_onProgress?: (progress: number) => void,
    _onProviderSwitch?: (currentProvider: JSBundleProvider) => void): Promise<ArrayBuffer> {
    this.lastMessage = ''
    this.report('Building...')
    try {
      const result = await this.fetchBundle()
      if (result.statusCode !== 200) {
        this.throwMetroError(result.data, result.statusCode ?? 0)
      }
      return result.data
    } catch (error) {
      if (error instanceof MetroJSBundleProviderError) {
        throw error
      }
      throw new JSBundleProviderError({
        whatHappened: `Couldn't load JSBundle from ${this.getURL()}`,
        extraData: error,
        howCanItBeFixed: [
          'Check that Metro is running and the device can reach its host and port.',
          'For USB debugging, check the hdc rport mapping.'
        ]
      })
    }
  }

  private report(message: string): void {
    if (message !== this.lastMessage) {
      this.lastMessage = message
      this.onMessage(message)
    }
  }

  private reportBuild(progress: QuecMetroBuildProgress): void {
    const value = typeof progress.percent === 'number' && Number.isFinite(progress.percent) ?
      progress.percent : Math.round(progress.done / progress.total * 100)
    const percent = Math.max(0, Math.min(100, value))
    this.report(`Building ${percent}% (${progress.done}/${progress.total})`)
  }

  private reportDownload(received: number, total: number): void {
    if (total > 0) {
      const percent = Math.max(0, Math.min(100, Math.round(received / total * 100)))
      this.report(`Downloading ${percent}%`)
    } else {
      this.report(`Downloading (${Math.round(received / 1024)} KB)`)
    }
  }

  private fetchBundle(): Promise<QuecMetroBundleResult> {
    return new Promise<QuecMetroBundleResult>((resolve, reject) => {
      const request = http.createHttp()
      let reader: QuecMetroMultipartReader | undefined = undefined
      let chunks: Uint8Array[] = []
      let headersReceived = false
      let statusCode: number | undefined = undefined
      let total = 0
      let received = 0
      let ended = false
      let settled = false

      const cleanUp = (): void => {
        try {
          request.off('headersReceive')
          request.off('dataReceive')
          request.off('dataEnd')
        } catch (error) {
        }
        try {
          request.destroy()
        } catch (error) {
        }
      }
      const fail = (error: Error): void => {
        if (!settled) {
          settled = true
          cleanUp()
          reject(error)
        }
      }
      const finish = (): void => {
        if (settled || !ended || statusCode === undefined || !headersReceived) {
          return
        }
        try {
          const result: QuecMetroBundleResult = reader !== undefined ? reader.finish() : {
            data: concatMetroChunks(chunks)
          }
          result.statusCode = result.statusCode ?? statusCode
          settled = true
          chunks = []
          cleanUp()
          resolve(result)
        } catch (error) {
          fail(error instanceof Error ? error : new Error('Invalid Metro response.'))
        }
      }
      request.on('headersReceive', (value: Object) => {
        if (settled || headersReceived) {
          return
        }
        try {
          const headers = value as Record<string, string>
          let contentType = ''
          for (const key of Object.keys(headers)) {
            if (key.toLowerCase() === 'content-type') {
              contentType = String(headers[key])
            } else if (key.toLowerCase() === 'content-length') {
              total = Number(headers[key])
            }
          }
          if (contentType.toLowerCase().includes('multipart/mixed')) {
            const boundary = /boundary\s*=\s*(?:"([^"]+)"|([^;\s]+))/i.exec(contentType)
            if (boundary === null) {
              throw new Error('The Metro multipart response has no boundary.')
            }
            reader = new QuecMetroMultipartReader(boundary[1] || boundary[2],
              (progress: QuecMetroBuildProgress) => this.reportBuild(progress),
              (size: number, length: number) => this.reportDownload(size, length))
            for (const chunk of chunks) {
              reader.append(chunk.buffer.slice(chunk.byteOffset, chunk.byteOffset + chunk.byteLength))
            }
            chunks = []
          }
          headersReceived = true
          finish()
        } catch (error) {
          fail(error instanceof Error ? error : new Error('Invalid Metro response headers.'))
        }
      })
      request.on('dataReceive', (chunk: ArrayBuffer) => {
        if (settled) {
          return
        }
        try {
          if (reader !== undefined) {
            reader.append(chunk)
          } else {
            chunks.push(new Uint8Array(chunk))
            received += chunk.byteLength
            if (headersReceived) {
              this.reportDownload(received, total)
            }
          }
        } catch (error) {
          fail(error instanceof Error ? error : new Error('Invalid Metro response body.'))
        }
      })
      request.on('dataEnd', () => {
        ended = true
        finish()
      })
      try {
        request.requestInStream(this.getURL(), {
          method: http.RequestMethod.GET,
          header: { 'Accept': 'multipart/mixed' },
          usingCache: false
        }, (error, code: number) => {
          if (error) {
            fail(new Error(error.message))
          } else {
            statusCode = code
            finish()
          }
        })
      } catch (error) {
        fail(error instanceof Error ? error : new Error('Failed to request the Metro bundle.'))
      }
    })
  }
}
