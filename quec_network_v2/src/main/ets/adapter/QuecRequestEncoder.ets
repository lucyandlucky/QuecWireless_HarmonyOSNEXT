import { JSON, url } from '@kit.ArkTS'
import { http } from '@kit.NetworkKit'
import { QuecNetworkError, QuecNetworkErrorType } from '../error/QuecNetworkError'
import {
  QuecBodyFormat,
  QuecFormBody,
  QuecHeaders,
  QuecQueryParams,
  QuecQueryValue,
  QuecRequestBody,
  QuecRequestMethod,
  QuecResponseType
} from '../model/QuecHttpTypes'
import { QuecRequestConfig } from '../model/QuecRequestConfig'

interface QuecEncodedBody {
  data: string | ArrayBuffer
  contentType: string
}

export interface QuecPreparedRequest {
  url: string
  options: http.HttpRequestOptions
}

export class QuecRequestEncoder {
  private invalidConfig(message: string, config: QuecRequestConfig): QuecNetworkError {
    return new QuecNetworkError({
      type: QuecNetworkErrorType.INVALID_CONFIG,
      message,
      config
    })
  }

  private createUrl(config: QuecRequestConfig): string {
    let parsedUrl: url.URL
    try {
      parsedUrl = url.URL.parseURL(config.url)
    } catch (error) {
      throw this.invalidConfig('Request URL must be an absolute HTTP(S) URL', config)
    }

    const protocol: string = parsedUrl.protocol.toLowerCase()
    if ((protocol !== 'http:' && protocol !== 'https:') || parsedUrl.hostname.length === 0) {
      throw this.invalidConfig('Request URL must be an absolute HTTP(S) URL', config)
    }

    const params: QuecQueryParams | undefined = config.params
    if (params !== undefined) {
      const encoded: string = this.encodeQueryParams(params)
      if (encoded.length > 0) {
        parsedUrl.search = parsedUrl.search.length > 1 ? `${parsedUrl.search}&${encoded}` : `?${encoded}`
      }
    }

    parsedUrl.hash = ''
    return parsedUrl.toString()
  }

  private toNativeMethod(method: QuecRequestMethod, config: QuecRequestConfig): http.RequestMethod {
    switch (method) {
      case QuecRequestMethod.GET:
        return http.RequestMethod.GET
      case QuecRequestMethod.POST:
        return http.RequestMethod.POST
      case QuecRequestMethod.PUT:
        return http.RequestMethod.PUT
      case QuecRequestMethod.DELETE:
        return http.RequestMethod.DELETE
      default:
        throw this.invalidConfig('Unsupported request method', config)
    }
  }

  private resolveBodyFormat(body: QuecRequestBody, config: QuecRequestConfig): QuecBodyFormat {
    if (config.bodyFormat !== undefined) {
      return config.bodyFormat
    }
    return typeof body === 'string' || body instanceof ArrayBuffer ? QuecBodyFormat.RAW : QuecBodyFormat.JSON
  }

  private encodePair(key: string, value: string): string {
    return `${encodeURIComponent(key)}=${encodeURIComponent(value)}`
  }

  private encodeForm(body: QuecRequestBody, config: QuecRequestConfig): string {
    if (body === null || typeof body !== 'object' || body instanceof ArrayBuffer || Array.isArray(body)) {
      throw this.invalidConfig('Form body must be a string-valued object', config)
    }

    const formBody: QuecFormBody = body as QuecFormBody
    const pairs: string[] = []
    Object.keys(formBody).forEach((key: string) => {
      const value: string = formBody[key]
      if (typeof value !== 'string') {
        throw this.invalidConfig('Form body values must be strings', config)
      }
      pairs.push(this.encodePair(key, value))
    })
    return pairs.join('&')
  }

  private encodeBody(config: QuecRequestConfig): QuecEncodedBody | undefined {
    const body: QuecRequestBody | undefined = config.body
    if (body === undefined) {
      return undefined
    }
    if (config.method === QuecRequestMethod.GET) {
      throw this.invalidConfig('GET request bodies are not supported on API 24', config)
    }

    const format: QuecBodyFormat = this.resolveBodyFormat(body, config)
    switch (format) {
      case QuecBodyFormat.JSON:
        if (body instanceof ArrayBuffer) {
          throw this.invalidConfig('ArrayBuffer cannot be encoded as JSON', config)
        }
        try {
          const data: string = JSON.stringify(body)
          return { data, contentType: 'application/json; charset=utf-8' }
        } catch (error) {
          throw this.invalidConfig('Request body cannot be encoded as JSON', config)
        }
      case QuecBodyFormat.FORM:
        return {
          data: this.encodeForm(body, config),
          contentType: 'application/x-www-form-urlencoded; charset=utf-8'
        }
      case QuecBodyFormat.RAW:
        if (typeof body === 'string') {
          return { data: body, contentType: 'text/plain; charset=utf-8' }
        }
        if (body instanceof ArrayBuffer) {
          return { data: body, contentType: 'application/octet-stream' }
        }
        throw this.invalidConfig('Raw body must be a string or ArrayBuffer', config)
      default:
        throw this.invalidConfig('Unsupported request body format', config)
    }
  }

  private createHeaders(config: QuecRequestConfig, body?: QuecEncodedBody): QuecHeaders {
    const headers: QuecHeaders = {}
    const requestHeaders: QuecHeaders | undefined = config.headers
    if (requestHeaders !== undefined) {
      Object.keys(requestHeaders).forEach((key: string) => {
        headers[key] = requestHeaders[key]
      })
    }

    if (body !== undefined) {
      const hasContentType: boolean = Object.keys(headers).some(
        (key: string) => key.toLowerCase() === 'content-type'
      )
      if (!hasContentType) {
        headers['Content-Type'] = body.contentType
      }
    }
    return headers
  }

  private validateTimeout(value: number | undefined, name: string, config: QuecRequestConfig): void {
    if (value !== undefined && (!Number.isInteger(value) || value < 0 || value > 4294967295)) {
      throw this.invalidConfig(`${name} must be a uint32 timeout in milliseconds`, config)
    }
  }

  public encodeQueryParams(params: QuecQueryParams): string {
    const pairs: string[] = []
    Object.keys(params).forEach((key: string) => {
      const value: QuecQueryValue | QuecQueryValue[] = params[key]
      if (Array.isArray(value)) {
        value.forEach((item: QuecQueryValue) => pairs.push(this.encodePair(key, String(item))))
      } else {
        pairs.push(this.encodePair(key, String(value)))
      }
    })
    return pairs.join('&')
  }

  public encodeOptions(config: QuecRequestConfig): http.HttpRequestOptions {
    this.validateTimeout(config.connectTimeout, 'connectTimeout', config)
    this.validateTimeout(config.readTimeout, 'readTimeout', config)

    const body: QuecEncodedBody | undefined = this.encodeBody(config)
    const headers: QuecHeaders = this.createHeaders(config, body)
    const options: http.HttpRequestOptions = {
      method: this.toNativeMethod(config.method, config),
      expectDataType: config.responseType === QuecResponseType.ARRAY_BUFFER
        ? http.HttpDataType.ARRAY_BUFFER
        : http.HttpDataType.STRING,
      usingCache: false
    }

    if (Object.keys(headers).length > 0) {
      options.header = headers
    }
    if (config.connectTimeout !== undefined) {
      options.connectTimeout = config.connectTimeout
    }
    if (config.readTimeout !== undefined) {
      options.readTimeout = config.readTimeout
    }
    if (body !== undefined && (typeof body.data !== 'string' || body.data.length > 0)) {
      options.extraData = body.data
    }

    return options
  }

  public encode(config: QuecRequestConfig): QuecPreparedRequest {
    return { url: this.createUrl(config), options: this.encodeOptions(config) }
  }
}
