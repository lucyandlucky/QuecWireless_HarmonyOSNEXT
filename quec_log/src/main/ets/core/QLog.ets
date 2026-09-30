import { common } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Log, Xlog } from '@ohos/xlog'

const LOG_PREFIX: string = 'QuecWireless'

enum LogLevel {
  VERBOSE,
  DEBUG,
  INFO,
  WARN,
  ERROR
}

export class QLog {
  public static readonly DOMAIN: number = 0x514C
  private static defaultTag: string = 'Quec'
  private static fileLogger: Log.LogInstance | undefined = undefined

  private static ensureDirectory(path: string): void {
    if (!fileIo.accessSync(path)) {
      fileIo.mkdirSync(path, true)
    }
  }

  private static writeFile(level: LogLevel, tag: string, content: string): void {
    const logger: Log.LogInstance | undefined = QLog.fileLogger
    if (logger === undefined) {
      return
    }
    try {
      switch (level) {
        case LogLevel.VERBOSE:
          logger.v(tag, content, null)
          break
        case LogLevel.DEBUG:
          logger.d(tag, content, null)
          break
        case LogLevel.INFO:
          logger.i(tag, content, null)
          break
        case LogLevel.WARN:
          logger.w(tag, content, null)
          break
        case LogLevel.ERROR:
          logger.e(tag, content, null)
          break
      }
      logger.appenderFlushSync()
    } catch (error) {
      QLog.fileLogger = undefined
      hilog.error(QLog.DOMAIN, 'QLog', 'XLog write failed: %{public}s', String(error))
    }
  }

  private static write(level: LogLevel, tagOrMessage: string | Error, message?: string | Error): void {
    const tag: string = message === undefined ? QLog.defaultTag : String(tagOrMessage)
    const value: string | Error = message === undefined ? tagOrMessage : message
    const content: string = value instanceof Error ? (value.stack ?? value.message) : value

    switch (level) {
      case LogLevel.VERBOSE:
        hilog.debug(QLog.DOMAIN, tag, '%{public}s', content)
        break
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
    QLog.writeFile(level, tag, content)
  }

  public static init(context: common.ApplicationContext, defaultTag: string = 'Quec'): void {
    QLog.defaultTag = defaultTag
    if (QLog.fileLogger !== undefined) {
      return
    }
    try {
      const logDir: string = `${context.filesDir}/xlog/log`
      const cacheDir: string = `${context.filesDir}/xlog/cache`
      QLog.ensureDirectory(logDir)
      QLog.ensureDirectory(cacheDir)
      Log.setLogImp(new Xlog())
      const logger: Log.LogInstance = Log.openLogInstance(
        Xlog.LEVEL_VERBOSE,
        Xlog.AppednerModeAsync,
        cacheDir,
        logDir,
        LOG_PREFIX,
        0
      )
      if (logger.mLogInstancePtr <= 0) {
        Log.closeLogInstance(LOG_PREFIX)
        throw new Error('XLog instance could not be opened')
      }
      QLog.fileLogger = logger
    } catch (error) {
      hilog.error(QLog.DOMAIN, 'QLog', 'XLog initialization failed: %{public}s', String(error))
    }
  }

  public static flush(): void {
    try {
      QLog.fileLogger?.appenderFlushSync()
    } catch (error) {
      hilog.error(QLog.DOMAIN, 'QLog', 'XLog flush failed: %{public}s', String(error))
    }
  }

  public static v(tagOrMessage: string, message?: string): void {
    QLog.write(LogLevel.VERBOSE, tagOrMessage, message)
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
