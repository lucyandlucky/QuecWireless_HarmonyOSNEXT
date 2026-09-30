import { AxiosError, AxiosRequestConfig, AxiosResponse, FormData, InternalAxiosRequestConfig } from '@ohos/axios'
import { QLog } from 'quec_log'

const TAG: string = 'QuecHttpLog'
const CHUNK_LENGTH: number = 256
const FRAME_WIDTH: number = 80

interface QuecLogRequestConfig extends AxiosRequestConfig {
  quecLogId?: number
  quecLogStartedAt?: number
  quecLogRequestLine?: string
  quecLogRequest?: string
}

export type QuecHttpLogWriter = (tag: string, message: string, isError: boolean) => void

function writeToQLog(tag: string, message: string, isError: boolean): void {
  if (isError) {
    QLog.e(tag, message)
  } else {
    QLog.i(tag, message)
  }
}

export class QuecHttpLog {
  private nextId: number = 0
  private readonly writer: QuecHttpLogWriter

  constructor(writer: QuecHttpLogWriter = writeToQLog) {
    this.writer = writer
  }

  private write(id: number, value: string, isError: boolean = false, prefix: string = ''): void {
    const lines: string[] = value.split('\n')
    for (let i: number = 0; i < lines.length; i++) {
      const line: string = lines[i]
      if (line.length === 0) {
        this.writer(TAG, `[${id}] ${prefix}`, isError)
        continue
      }
      let start: number = 0
      while (start < line.length) {
        let end: number = Math.min(start + CHUNK_LENGTH, line.length)
        if (end < line.length) {
          const lastCode: number = line.charCodeAt(end - 1)
          if (lastCode >= 0xD800 && lastCode <= 0xDBFF) {
            end--
          }
        }
        const chunk: string = line.slice(start, end)
        this.writer(TAG, `[${id}] ${prefix}${chunk}`, isError)
        start = end
      }
    }
  }

  private writeFrame(id: number, title: string, content: string, isError: boolean): void {
    const header: string = `┌────── ${title} ${'─'.repeat(Math.max(0, FRAME_WIDTH - title.length - 9))}`
    const footer: string = `└${'─'.repeat(FRAME_WIDTH - 1)}`
    this.write(id, header, isError)
    this.write(id, content, isError, '│ ')
    this.write(id, footer, isError)
  }

  private formatValue(value: Object | null | undefined): string {
    if (value === undefined) {
      return '(none)'
    }
    if (value === null) {
      return 'null'
    }
    if (typeof value === 'string') {
      return value
    }
    if (value instanceof ArrayBuffer) {
      const bytes: Uint8Array = new Uint8Array(value)
      let hex: string = ''
      for (let i: number = 0; i < bytes.length; i++) {
        const byte: number = bytes[i]
        hex += (byte < 16 ? '0' : '') + byte.toString(16)
      }
      return `0x${hex}`
    }
    if (value instanceof FormData) {
      const fields: string[] = []
      value.forEach((field: Object, key?: string, option?: Object) => {
        fields.push(
          `${key ?? ''}: ${this.formatValue(field)}${option === undefined ? '' : ` (${this.formatValue(option)})`}`)
      })
      return fields.join('\n')
    }
    try {
      const json: string | undefined = JSON.stringify(value, null, 2)
      return json === undefined ? String(value) : json
    } catch (error) {
      return String(value)
    }
  }

  private formatStartTime(timestamp: number): string {
    const date: Date = new Date(timestamp)
    const pad = (value: number, length: number): string => value.toString().padStart(length, '0')
    const offset: number = -date.getTimezoneOffset()
    const sign: string = offset >= 0 ? '+' : '-'
    return `${date.getFullYear()}-${pad(date.getMonth() + 1, 2)}-${pad(date.getDate(), 2)} ` +
      `${pad(date.getHours(), 2)}:${pad(date.getMinutes(), 2)}:${pad(date.getSeconds(), 2)}.` +
      `${pad(date.getMilliseconds(), 3)} ${sign}${pad(Math.floor(Math.abs(offset) / 60), 2)}:` +
      `${pad(Math.abs(offset) % 60, 2)}`
  }

  private getRequestId(config: InternalAxiosRequestConfig | undefined): number {
    return config === undefined ? 0 : ((config as QuecLogRequestConfig).quecLogId ?? 0)
  }

  private getDuration(config: InternalAxiosRequestConfig | undefined): string {
    const startedAt: number | undefined = config === undefined ? undefined :
      (config as QuecLogRequestConfig).quecLogStartedAt
    return startedAt === undefined ? '' : `, ${Date.now() - startedAt}ms`
  }

  private getRequestLine(config: InternalAxiosRequestConfig | undefined): string {
    return config === undefined ? '(request address unavailable)' :
      ((config as QuecLogRequestConfig).quecLogRequestLine ?? '(request address unavailable)')
  }

  private takeRequest(config: InternalAxiosRequestConfig | undefined): string {
    if (config === undefined) {
      return '(request details unavailable)'
    }
    const context: QuecLogRequestConfig = config as QuecLogRequestConfig
    const request: string = context.quecLogRequest ?? '(request details unavailable)'
    context.quecLogRequest = undefined
    context.quecLogRequestLine = undefined
    return request
  }

  private formatResponse(response: AxiosResponse): string {
    return `${this.getRequestLine(response.config)}\nHTTP ${response.status}${this.getDuration(
      response.config)}\n` +
      `Headers: ${this.formatValue(response.headers as Object)}\n` +
      `Body: ${this.formatValue(response.data as Object | null | undefined)}`
  }

  private flush(config: InternalAxiosRequestConfig | undefined, result: string, isError: boolean): void {
    const id: number = this.getRequestId(config)
    const request: string = this.takeRequest(config)
    this.writeFrame(id, 'Request', request, isError)
    this.writeFrame(id, isError ? 'Response Error' : 'Response', result, isError)
  }

  public request(config: InternalAxiosRequestConfig, url: string): void {
    const context: QuecLogRequestConfig = config as QuecLogRequestConfig
    context.quecLogId = ++this.nextId
    context.quecLogStartedAt = Date.now()
    context.quecLogRequestLine = `${(config.method ?? 'GET').toUpperCase()} ${url}`
    context.quecLogRequest = `${context.quecLogRequestLine}\n` +
      `Start Time: ${this.formatStartTime(context.quecLogStartedAt)}\n` +
      `Headers: ${this.formatValue(config.headers.toJSON())}\n` +
      `Params: ${this.formatValue(config.params as Object | undefined)}\n` +
      `Body: ${this.formatValue(config.data as Object | undefined)}`
  }

  public response(response: AxiosResponse): void {
    this.flush(response.config, this.formatResponse(response), false)
  }

  public error(error: Error): void {
    const axiosError: AxiosError = error as AxiosError
    if (axiosError.response !== undefined) {
      this.flush(axiosError.response.config, `${this.formatResponse(axiosError.response)}\nError: ${error.message}`,
        true)
      return
    }
    this.flush(
      axiosError.config,
      `${this.getRequestLine(axiosError.config)}\nERROR${this.getDuration(axiosError.config)}\n` +
        `Code: ${axiosError.code ?? '(none)'}\nError: ${error.message}`
      , true)
  }
}
