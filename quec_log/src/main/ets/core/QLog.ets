import { hilog } from '@kit.PerformanceAnalysisKit'

enum LogLevel {
  DEBUG,
  INFO,
  WARN,
  ERROR
}

export class QLog {
  public static readonly DOMAIN: number = 0x514C
  private static defaultTag: string = 'Quec'

  private static write(level: LogLevel, tagOrMessage: string | Error, message?: string | Error): void {
    const tag: string = message === undefined ? QLog.defaultTag : String(tagOrMessage)
    const value: string | Error = message === undefined ? tagOrMessage : message
    const content: string = value instanceof Error ? (value.stack ?? value.message) : value

    switch (level) {
      case LogLevel.DEBUG:
        hilog.debug(QLog.DOMAIN, tag, '%{public}s', content)
        break
      case LogLevel.INFO:
        hilog.info(QLog.DOMAIN, tag, '%{public}s', content)
        break
      case LogLevel.WARN:
        hilog.warn(QLog.DOMAIN, tag, '%{public}s', content)
        break
      case LogLevel.ERROR:
        hilog.error(QLog.DOMAIN, tag, '%{public}s', content)
        break
    }
  }

  public static init(defaultTag: string = 'Quec'): void {
    QLog.defaultTag = defaultTag
  }

  public static v(tagOrMessage: string, message?: string): void {
    QLog.write(LogLevel.DEBUG, tagOrMessage, message)
  }

  public static d(tagOrMessage: string, message?: string): void {
    QLog.write(LogLevel.DEBUG, tagOrMessage, message)
  }

  public static i(tagOrMessage: string, message?: string): void {
    QLog.write(LogLevel.INFO, tagOrMessage, message)
  }

  public static w(tagOrMessage: string, message?: string): void {
    QLog.write(LogLevel.WARN, tagOrMessage, message)
  }

  public static e(tagOrMessage: string | Error, message?: string | Error): void {
    QLog.write(LogLevel.ERROR, tagOrMessage, message)
  }
}
