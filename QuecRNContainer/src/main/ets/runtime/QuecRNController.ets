import { UIContext } from '@kit.ArkUI'
import { QLog } from '@quec/log'
import {
  buildRNComponentForTag,
  DisplayMode,
  FileJSBundleProvider,
  JSBundleProvider,
  ResourceJSBundleProvider,
  RNComponentContext,
  RNInstanceImpl,
  RNOHContext,
  RNOHCoreContext,
  RNOHError,
  RNPackage,
  SurfaceHandle
} from '@rnoh/react-native-openharmony'

import { buildQuecRNComponent } from '../components/QuecRNComponentBuilder'
import { QuecRNError } from '../model/QuecRNError'
import { QuecRNBundleSource, QuecRNLoadInfo } from '../model/QuecRNLoadInfo'
import { QuecMetroJSBundleProvider } from './QuecMetroJSBundleProvider'

const TAG: string = 'QuecRNController'

interface I18nConstants {
  isRTL: boolean
}

interface I18nManager {
  getConstants(): I18nConstants
}

export class QuecRNRenderContext {
  readonly context: RNComponentContext
  readonly surface: SurfaceHandle

  constructor(context: RNComponentContext, surface: SurfaceHandle) {
    this.context = context
    this.surface = surface
  }
}

export class QuecRNController {
  private coreContext: RNOHCoreContext | undefined = undefined
  private instance: RNInstanceImpl | undefined = undefined
  private renderContext: QuecRNRenderContext | undefined = undefined
  private loadTask: Promise<QuecRNRenderContext | undefined> | undefined = undefined
  private reloadTask: Promise<QuecRNRenderContext | undefined> | undefined = undefined
  private releaseTask: Promise<void> | undefined = undefined
  private disposed: boolean = false
  private active: boolean = true
  private attached: boolean = false
  private uiContext: UIContext | undefined = undefined
  private width: number = 0
  private height: number = 0
  private offsetX: number = 0
  private offsetY: number = 0
  private info: QuecRNLoadInfo | undefined = undefined
  private cleanUpCallbacks: (() => void)[] = []
  private unsubscribeReload: (() => void) | undefined = undefined
  private onBack: () => void = () => {
  }
  private onError: (error: QuecRNError) => void = () => {
  }
  private onReload: () => void = () => {
  }

  public load(
    info: QuecRNLoadInfo,
    onBack: () => void,
    onError: (error: QuecRNError) => void = () => {
    },
    onReload: () => void = () => {
    }
  ): Promise<QuecRNRenderContext | undefined> {
    if (this.disposed) {
      return Promise.resolve(undefined)
    }
    if (this.loadTask === undefined) {
      this.info = info
      this.onBack = onBack
      this.onError = onError
      this.onReload = onReload
      this.loadTask = this.createRenderContext(info)
    }
    return this.loadTask
  }

  private async createRenderContext(
    info: QuecRNLoadInfo,
    previousInstance?: RNInstanceImpl
  ): Promise<QuecRNRenderContext | undefined> {
    try {
      const coreContext = AppStorage.get<RNOHCoreContext>('RNOHCoreContext')
      if (coreContext === undefined) {
        throw new Error('RNOHCoreContext is unavailable. Initialize the host with RNAbility first.')
      }
      this.coreContext = coreContext
      this.subscribeToReload(coreContext, info)
      let instance: RNInstanceImpl
      if (previousInstance !== undefined) {
        instance = await coreContext.reloadRNInstance(previousInstance) as RNInstanceImpl
      } else {
        instance = await coreContext.createAndRegisterRNInstance({
          name: info.bundleId,
          createRNPackages: (): RNPackage[] => [],
          enableDebugger: coreContext.isDebugModeEnabled && info.bundleSource === QuecRNBundleSource.Metro,
          assetsDest: info.assetsDest,
          backPressHandler: () => {
            if (!this.disposed && this.active) {
              this.onBack()
            }
          }
        }) as RNInstanceImpl
      }
      this.instance = instance
      if (this.disposed) {
        return undefined
      }
      this.cleanUpCallbacks.push(instance.subscribeToRNOHErrors((error: RNOHError) => {
        if (!this.disposed) {
          this.reportInstanceError(info, instance, error, this.onError)
        }
      }))
      const provider = this.createBundleProvider(coreContext, info, instance)
      await instance.runJSBundle(provider)
      if (this.disposed) {
        return undefined
      }
      // runJSBundle reports failures through RNOH instead of rejecting its Promise.
      if (instance.getBundleExecutionStatus(provider.getURL()) !== 'DONE') {
        throw new Error('The RN bundle did not finish loading.')
      }
      const context = new RNComponentContext(
        RNOHContext.fromCoreContext(coreContext, instance),
        wrapBuilder(buildQuecRNComponent),
        wrapBuilder(buildRNComponentForTag),
        new Map()
      )
      this.renderContext = new QuecRNRenderContext(context, instance.createSurface(info.appKey))
      this.cleanUpCallbacks.push(instance.subscribeToLifecycleEvents('FOREGROUND', () => {
        // RNAbility resumes all instances; restore this container's visibility afterwards.
        Promise.resolve().then(() => {
          if (!this.disposed) {
            const visible = this.active && coreContext.getUIAbilityState() === 'FOREGROUND'
            this.updateSurfaceVisibility(visible)
            if (!visible) {
              instance.onBackground()
            }
          }
        })
      }))
      this.cleanUpCallbacks.push(instance.subscribeToLifecycleEvents('BACKGROUND', () => {
        this.updateSurfaceVisibility(false)
      }))
      this.syncVisibility()
      QLog.i(TAG, `loaded bundle '${info.bundleId}', instance ${instance.getId()}`)
      return this.renderContext
    } catch (error) {
      await this.release()
      throw new Error(error instanceof Error ? error.message : 'Failed to initialize the RN container.')
    }
  }

  private subscribeToReload(coreContext: RNOHCoreContext, info: QuecRNLoadInfo): void {
    if (this.unsubscribeReload !== undefined || !coreContext.isDebugModeEnabled ||
      info.bundleSource !== QuecRNBundleSource.Metro) {
      return
    }
    this.unsubscribeReload = coreContext.devToolsController.eventEmitter.subscribe('RELOAD', () => {
      if (!this.disposed && this.active) {
        this.onReload()
      }
    })
  }

  public reload(): Promise<QuecRNRenderContext | undefined> {
    if (this.disposed || this.info === undefined || this.info.bundleSource !== QuecRNBundleSource.Metro ||
      this.coreContext?.isDebugModeEnabled !== true) {
      return Promise.resolve(undefined)
    }
    if (this.reloadTask !== undefined) {
      return this.reloadTask
    }
    const task = this.reloadRenderContext(this.info, this.loadTask)
    this.reloadTask = task
    this.loadTask = task
    task.then(() => this.reloadTask = undefined, () => this.reloadTask = undefined)
    return task
  }

  private async reloadRenderContext(info: QuecRNLoadInfo,
    previousLoad: Promise<QuecRNRenderContext | undefined> | undefined): Promise<QuecRNRenderContext | undefined> {
    try {
      await previousLoad
    } catch (error) {
      // A failed Metro request can be retried with Reload.
    }
    if (this.disposed) {
      return undefined
    }
    await this.releaseSurface()
    if (this.disposed) {
      return undefined
    }
    this.releaseTask = undefined
    QLog.i(TAG, `reloading bundle '${info.bundleId}'`)
    return this.createRenderContext(info, this.instance)
  }

  private reportInstanceError(
    info: QuecRNLoadInfo,
    instance: RNInstanceImpl,
    error: RNOHError,
    onError: (error: QuecRNError) => void
  ): void {
    const stack = error.getStack()
    const report: QuecRNError = {
      bundleId: info.bundleId,
      appKey: info.appKey,
      bundlePath: info.bundlePath,
      instanceId: instance.getId(),
      message: error.getMessage() || 'Unknown RN error',
      stack: typeof stack === 'string' ? stack : (stack?.toString() ?? '')
    }
    const prefix = `[bundle=${report.bundleId}, instance=${report.instanceId}, appKey=${report.appKey}]`
    QLog.e(TAG, `${prefix} ${report.message}`)
    report.stack.split('\n').filter(line => line.length > 0).forEach(line => QLog.e(TAG, `${prefix} ${line}`))
    try {
      onError(report)
    } catch (callbackError) {
      const message = callbackError instanceof Error ? callbackError.message : 'Unknown error'
      QLog.e(TAG, `${prefix} onError callback failed: ${message}`)
    }
  }

  private createBundleProvider(
    coreContext: RNOHCoreContext,
    info: QuecRNLoadInfo,
    instance: RNInstanceImpl
  ): JSBundleProvider {
    if (info.bundleSource === QuecRNBundleSource.File) {
      return new FileJSBundleProvider(info.bundlePath, [info.appKey])
    } else if (info.bundleSource === QuecRNBundleSource.Metro) {
      return new QuecMetroJSBundleProvider(info.bundlePath, [info.appKey], (message: string) => {
        if (!this.disposed && this.active && this.instance === instance) {
          coreContext.devToolsController.eventEmitter.emit('SHOW_DEV_LOADING_VIEW', instance.getId(), message)
        }
      })
    }
    return new ResourceJSBundleProvider(coreContext.uiAbilityContext.resourceManager,
      info.bundlePath, [info.appKey])
  }

  public attachSurface(uiContext: UIContext): void {
    this.uiContext = uiContext
    this.attached = true
    this.startSurface()
  }

  public detachSurface(): void {
    this.attached = false
    this.uiContext = undefined
  }

  public updateLayout(width: number, height: number, offsetX: number, offsetY: number): void {
    this.width = width
    this.height = height
    this.offsetX = offsetX
    this.offsetY = offsetY
    this.startSurface()
  }

  private startSurface(): void {
    const surface = this.renderContext?.surface
    if (this.disposed || !this.attached || this.uiContext === undefined || this.instance === undefined ||
      surface === undefined || surface.isDestroyed() || surface.isRunning() || this.width <= 0 || this.height <= 0) {
      return
    }
    surface.start(
      {
        width: this.width,
        height: this.height,
        surfaceOffsetX: this.offsetX,
        surfaceOffsetY: this.offsetY,
        pixelRatio: this.uiContext.vp2px(1),
        isRTL: this.instance.getTurboModule<I18nManager>('I18nManager').getConstants().isRTL
      },
      this.info?.initialProps ?? {}
    )
    this.syncVisibility()
  }

  public setActive(active: boolean): void {
    this.active = active
    this.syncVisibility()
  }

  private syncVisibility(): void {
    if (this.disposed || this.instance === undefined || this.renderContext === undefined) {
      return
    }
    const visible = this.active && this.coreContext?.getUIAbilityState() === 'FOREGROUND'
    this.updateSurfaceVisibility(visible)
    if (visible) {
      this.instance.onForeground()
    } else {
      this.instance.onBackground()
    }
  }

  private updateSurfaceVisibility(visible: boolean): void {
    const surface = this.renderContext?.surface
    if (surface !== undefined && !surface.isDestroyed()) {
      surface.setDisplayMode(visible ? DisplayMode.Visible : DisplayMode.Suspended)
    }
  }

  public handleBackPress(): boolean {
    if (this.disposed || !this.active || this.instance === undefined ||
      this.renderContext?.surface.isRunning() !== true) {
      return false
    }
    this.instance.onBackPress()
    return true
  }

  public async dispose(): Promise<void> {
    this.disposed = true
    this.unsubscribeReload?.()
    this.unsubscribeReload = undefined
    try {
      await this.loadTask
    } catch (error) {
      // Failed loads have already released their resources.
    }
    await this.release()
  }

  private release(): Promise<void> {
    if (this.releaseTask === undefined) {
      this.releaseTask = this.releaseResources()
    }
    return this.releaseTask
  }

  private async releaseResources(): Promise<void> {
    await this.releaseSurface()
    const instance = this.instance
    if (instance !== undefined && this.coreContext !== undefined) {
      await this.coreContext.destroyAndUnregisterRNInstance(instance)
      QLog.i(TAG, `released instance ${instance.getId()}`)
    }
    this.instance = undefined
  }

  private async releaseSurface(): Promise<void> {
    this.cleanUpCallbacks.forEach(cleanUp => cleanUp())
    this.cleanUpCallbacks = []
    const surface = this.renderContext?.surface
    if (surface !== undefined && !surface.isDestroyed()) {
      if (surface.isRunning()) {
        await surface.stop()
      }
      surface.destroy()
    }
    this.renderContext = undefined
    this.detachSurface()
  }
}
