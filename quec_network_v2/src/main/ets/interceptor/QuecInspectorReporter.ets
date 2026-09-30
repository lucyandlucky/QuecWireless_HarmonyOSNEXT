import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN: number = 0x514C
const TAG: string = 'QuecInspector'
const CHUNK_LENGTH: number = 320

export interface QuecInspectorEvent {
  phase: 'request' | 'response' | 'error'
  id: number
  time: number
  startedAt: number
  durationMs?: number
  method: string
  url: string
  requestHeaders: Object
  requestBody?: string
  requestBodyType?: string
  status?: number
  responseHeaders?: Object
  responseBody?: string
  responseBodyType?: string
  error?: string
}

export type QuecInspectorWriter = (message: string) => void

function writeToHiLog(message: string): void {
  hilog.info(DOMAIN, TAG, '%{public}s', message)
}

export class QuecInspectorReporter {
  private readonly sessionId: string = `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 8)}`
  private readonly writer: QuecInspectorWriter
  private nextEventId: number = 0

  constructor(writer: QuecInspectorWriter = writeToHiLog) {
    this.writer = writer
  }

  public emit(event: QuecInspectorEvent): void {
    const json: string | undefined = JSON.stringify(event)
    if (json === undefined) {
      return
    }
    const payload: string = encodeURIComponent(json)
    const count: number = Math.max(1, Math.ceil(payload.length / CHUNK_LENGTH))
    const eventId: number = ++this.nextEventId
    for (let index: number = 0; index < count; index++) {
      const chunk: string = payload.slice(index * CHUNK_LENGTH, (index + 1) * CHUNK_LENGTH)
      this.writer(`QNI1|${this.sessionId}|${eventId}|${index + 1}/${count}|${chunk}`)
    }
  }
}
