import { util } from '@kit.ArkTS'

export interface QuecMetroBuildProgress {
  done: number
  total: number
  percent?: number
}

export interface QuecMetroBundleResult {
  data: ArrayBuffer
  statusCode?: number
}

enum MultipartState {
  Preamble,
  Headers,
  Body,
  End
}

export function concatMetroChunks(chunks: Uint8Array[]): ArrayBuffer {
  let length = 0
  for (const chunk of chunks) {
    length += chunk.length
  }
  const result = new Uint8Array(length)
  let offset = 0
  for (const chunk of chunks) {
    result.set(chunk, offset)
    offset += chunk.length
  }
  return result.buffer
}

function asciiBytes(value: string): Uint8Array {
  const result = new Uint8Array(value.length)
  for (let index = 0; index < value.length; index++) {
    result[index] = value.charCodeAt(index)
  }
  return result
}

function findBytes(data: Uint8Array, target: Uint8Array): number {
  for (let index = 0; index <= data.length - target.length; index++) {
    let matched = true
    for (let offset = 0; offset < target.length; offset++) {
      if (data[index + offset] !== target[offset]) {
        matched = false
        break
      }
    }
    if (matched) {
      return index
    }
  }
  return -1
}

export class QuecMetroMultipartReader {
  private state: MultipartState = MultipartState.Preamble
  private buffer: Uint8Array = new Uint8Array(0)
  private firstBoundary: Uint8Array
  private boundary: Uint8Array
  private headerEnd: Uint8Array = asciiBytes('\r\n\r\n')
  private headers: Map<string, string> = new Map()
  private chunks: Uint8Array[] = []
  private received: number = 0
  private total: number = 0
  private downloading: boolean = false
  private result: QuecMetroBundleResult | undefined = undefined
  private onBuild: (progress: QuecMetroBuildProgress) => void
  private onDownload: (received: number, total: number) => void

  constructor(boundary: string, onBuild: (progress: QuecMetroBuildProgress) => void,
    onDownload: (received: number, total: number) => void) {
    this.firstBoundary = asciiBytes(`--${boundary}\r\n`)
    this.boundary = asciiBytes(`\r\n--${boundary}`)
    this.onBuild = onBuild
    this.onDownload = onDownload
  }

  public append(chunk: ArrayBuffer): void {
    if (this.state === MultipartState.End) {
      return
    }
    const combined = new Uint8Array(this.buffer.length + chunk.byteLength)
    combined.set(this.buffer)
    combined.set(new Uint8Array(chunk), this.buffer.length)
    this.buffer = combined
    while (this.advance()) {
    }
  }

  public finish(): QuecMetroBundleResult {
    if (this.state !== MultipartState.End || this.result === undefined) {
      throw new Error('The Metro multipart response ended before the bundle was complete.')
    }
    return this.result
  }

  private advance(): boolean {
    if (this.state === MultipartState.Preamble) {
      const index = findBytes(this.buffer, this.firstBoundary)
      if (index < 0) {
        this.buffer = this.buffer.slice(Math.max(0, this.buffer.length - this.firstBoundary.length + 1))
        return false
      }
      this.buffer = this.buffer.slice(index + this.firstBoundary.length)
      this.state = MultipartState.Headers
      return true
    }
    if (this.state === MultipartState.Headers) {
      return this.readHeaders()
    }
    if (this.state === MultipartState.Body) {
      return this.readBody()
    }
    return false
  }

  private readHeaders(): boolean {
    const index = findBytes(this.buffer, this.headerEnd)
    if (index < 0) {
      if (this.buffer.length > 65536) {
        throw new Error('The Metro multipart headers are too large.')
      }
      return false
    }
    const text = util.TextDecoder.create().decodeToString(this.buffer.subarray(0, index))
    this.headers = new Map()
    for (const line of text.split('\r\n')) {
      const separator = line.indexOf(':')
      if (separator > 0) {
        this.headers.set(line.substring(0, separator).trim().toLowerCase(), line.substring(separator + 1).trim())
      }
    }
    this.chunks = []
    this.received = 0
    const length = Number(this.headers.get('content-length'))
    this.total = Number.isFinite(length) && length > 0 ? length : 0
    this.downloading = (this.headers.get('content-type') ?? '').toLowerCase().includes('javascript')
    if (this.downloading) {
      this.onDownload(0, this.total)
    }
    this.buffer = this.buffer.slice(index + this.headerEnd.length)
    this.state = MultipartState.Body
    return true
  }

  private readBody(): boolean {
    const index = findBytes(this.buffer, this.boundary)
    if (index < 0) {
      // 留下可能跨越下一个网络数据块的分隔符。
      const length = Math.max(0, this.buffer.length - this.boundary.length - 1)
      this.appendBody(this.buffer.subarray(0, length))
      this.buffer = this.buffer.slice(length)
      return false
    }
    const suffix = index + this.boundary.length
    if (this.buffer.length < suffix + 2) {
      this.appendBody(this.buffer.subarray(0, index))
      this.buffer = this.buffer.slice(index)
      return false
    }
    const last = this.buffer[suffix] === 45 && this.buffer[suffix + 1] === 45
    const next = this.buffer[suffix] === 13 && this.buffer[suffix + 1] === 10
    if (!last && !next) {
      this.appendBody(this.buffer.subarray(0, index + 1))
      this.buffer = this.buffer.slice(index + 1)
      return true
    }
    this.appendBody(this.buffer.subarray(0, index))
    this.completePart(last)
    this.buffer = this.buffer.slice(suffix + 2)
    this.state = last ? MultipartState.End : MultipartState.Headers
    return true
  }

  private appendBody(data: Uint8Array): void {
    if (data.length === 0) {
      return
    }
    this.chunks.push(data)
    this.received += data.length
    if (this.downloading) {
      this.onDownload(this.received, this.total)
    }
  }

  private completePart(last: boolean): void {
    const data = concatMetroChunks(this.chunks)
    this.chunks = []
    if (last) {
      const status = Number(this.headers.get('x-http-status'))
      this.result = {
        data: data,
        statusCode: Number.isFinite(status) && status > 0 ? status : undefined
      }
      if (this.downloading) {
        this.onDownload(this.received, this.received)
      }
      return
    }
    if (!(this.headers.get('content-type') ?? '').toLowerCase().includes('application/json')) {
      return
    }
    let progress: QuecMetroBuildProgress
    try {
      progress = JSON.parse(util.TextDecoder.create().decodeToString(new Uint8Array(data))) as QuecMetroBuildProgress
    } catch (error) {
      return
    }
    if (progress !== null && typeof progress.done === 'number' && Number.isFinite(progress.done) &&
      typeof progress.total === 'number' && Number.isFinite(progress.total) &&
      progress.done >= 0 && progress.total > 0) {
      this.onBuild(progress)
    }
  }
}
