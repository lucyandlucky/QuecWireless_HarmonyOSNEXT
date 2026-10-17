import { QuecDialog, QuecDialogContent, QuecDialogHandle } from '@quec/basic-ui'
import { QLog } from '@quec/log'
import {
  LogBoxDialog,
  LogBoxTurboModule,
  RNOHCoreContext,
  RNOHErrorDialog,
  RNSurface
} from '@rnoh/react-native-openharmony'
import { RNDevLoadingView } from '@rnoh/react-native-openharmony/src/main/ets/RNOH/RNDevLoadingView'

import { QuecRNError } from '../model/QuecRNError'
import { QuecRNBundleSource, QuecRNLoadInfo } from '../model/QuecRNLoadInfo'
import { QuecRNController, QuecRNRenderContext } from '../runtime/QuecRNController'
import { buildQuecRNErrorDialog, QuecRNErrorDialogData } from './QuecRNErrorDialog'

@ComponentV2
export struct QuecRNView {
  @Require @Param info: QuecRNLoadInfo
  @Require @Param controller: QuecRNController
  @Param active: boolean = true
  @Event onBack: () => void = () => {
  }
  @Event onError: (error: QuecRNError) => void = () => {
  }
  @Local private renderContext: QuecRNRenderContext | undefined = undefined
  @Local private failed: boolean = false
  private mounted: boolean = false
  private leaving: boolean = false
  private loadTask: Promise<void> | undefined = undefined
  private reloadTask: Promise<void> | undefined = undefined
  private devLoadingMounted: boolean = false
  private surfaceMounted: boolean = false
  private onSurfaceDetached: (() => void) | undefined = undefined
  private errorDialog: QuecDialogHandle<QuecRNErrorDialogData> | undefined = undefined
  private logBoxDialog: CustomDialogController | undefined = undefined
  private logBoxClosed: Promise<void> | undefined = undefined
  private onLogBoxClosed: (() => void) | undefined = undefined
  private devCleanUpCallbacks: (() => void)[] = []

  aboutToAppear(): void {
    this.mounted = true
    this.updateActive()
  }

  @Monitor('active')
  private updateActive(): void {
    this.controller.setActive(this.active)
    if (!this.mounted) {
      return
    }
    if (!this.active) {
      this.dismissDevErrorDialog()
      this.closeLogBoxDialog().catch((error: Error) => QLog.e('QuecRNView', error))
      this.closeFailureDialog()
        .then(() => this.showFailureDialog())
        .catch((error: Error) => QLog.e('QuecRNView', error))
    } else if (this.failed) {
      this.showFailureDialog()
    } else if (this.renderContext === undefined && this.loadTask === undefined && this.reloadTask === undefined) {
      if (this.isMetroDebug() && !this.devLoadingMounted) {
        return
      }
      this.loadTask = this.load()
    }
  }

  private async load(): Promise<void> {
    try {
      const context = await this.controller.load(
        this.info,
        () => this.onBack(),
        (error: QuecRNError) => {
          if (this.mounted) {
            this.failed = true
            this.showFailureDialog()
            this.onError(error)
          }
        }, () => this.reload())
      if (this.mounted) {
        this.setUpLogBox(context)
        this.renderContext = context
      }
    } catch (error) {
      this.handleLoadError(error instanceof Error ? error : new Error('Unknown error'))
    }
  }

  private reload(): void {
    if (!this.mounted || !this.active || this.leaving || this.reloadTask !== undefined) {
      return
    }
    const task = this.reloadContainer()
    this.reloadTask = task
    task.then(() => this.reloadTask = undefined)
  }

  private async reloadContainer(): Promise<void> {
    try {
      await this.loadTask
      if (!this.mounted || !this.active || this.leaving) {
        return
      }
      this.failed = false
      await this.closeFailureDialog()
      this.dismissDevErrorDialog()
      await this.cleanUpLogBox()
      await this.unmountSurface()
      if (!this.mounted || this.leaving) {
        return
      }
      const context = await this.controller.reload()
      if (this.mounted) {
        this.setUpLogBox(context)
        this.renderContext = context
      }
    } catch (error) {
      this.handleLoadError(error instanceof Error ? error : new Error('Unknown error'))
    }
  }

  private unmountSurface(): Promise<void> {
    const detached = this.surfaceMounted ? new Promise<void>((resolve) => {
      this.onSurfaceDetached = resolve
    }) : Promise.resolve()
    this.renderContext = undefined
    return detached
  }

  private handleLoadError(error: Error): void {
    if (!this.mounted) {
      return
    }
    this.failed = true
    QLog.e('QuecRNView', `failed to load bundle '${this.info.bundleId}': ${error.message}`)
    if (error.stack) {
      QLog.e('QuecRNView', error.stack)
    }
    this.showFailureDialog()
  }

  aboutToDisappear(): void {
    this.mounted = false
    this.dismissDevErrorDialog()
    this.closeFailureDialog().catch((error: Error) => QLog.e('QuecRNView', error))
    this.cleanUpLogBox().then(() => this.controller.dispose())
      .catch(() => QLog.e('QuecRNView', 'failed to release the RN container'))
  }

  private isMetro(): boolean {
    return this.info.bundleSource === QuecRNBundleSource.Metro
  }

  private isMetroDebug(): boolean {
    return this.isMetro() &&
      AppStorage.get<RNOHCoreContext>('RNOHCoreContext')?.isDebugModeEnabled === true
  }

  private setUpLogBox(context: QuecRNRenderContext | undefined): void {
    if (!this.isMetro() || context === undefined || !context.context.isDebugModeEnabled) {
      return
    }
    this.logBoxDialog = new CustomDialogController({
      cornerRadius: 0,
      customStyle: true,
      alignment: DialogAlignment.TopStart,
      backgroundColor: Color.Transparent,
      builder: LogBoxDialog({ ctx: context.context, initialProps: this.info.initialProps ?? {} }),
      onDidDisappear: () => {
        this.onLogBoxClosed?.()
        this.onLogBoxClosed = undefined
        this.logBoxClosed = undefined
      }
    })
    const logBox = context.context.rnInstance.getTurboModule<LogBoxTurboModule>(LogBoxTurboModule.NAME)
    this.devCleanUpCallbacks.push(logBox.eventEmitter.subscribe('SHOW', () => {
      if (!this.mounted || !this.active || this.leaving || this.reloadTask !== undefined ||
        this.logBoxClosed !== undefined) {
        return
      }
      this.logBoxClosed = new Promise<void>((resolve) => this.onLogBoxClosed = resolve)
      this.logBoxDialog?.open()
    }))
    this.devCleanUpCallbacks.push(logBox.eventEmitter.subscribe('HIDE', () => {
      this.closeLogBoxDialog().catch((error: Error) => QLog.e('QuecRNView', error))
    }))
  }

  private async closeLogBoxDialog(): Promise<void> {
    const closed = this.logBoxClosed
    if (closed !== undefined) {
      this.logBoxDialog?.close()
      await closed
    }
  }

  private async cleanUpLogBox(): Promise<void> {
    this.devCleanUpCallbacks.forEach(cleanUp => cleanUp())
    this.devCleanUpCallbacks = []
    await this.closeLogBoxDialog()
    this.logBoxDialog = undefined
  }

  private dismissDevErrorDialog(): void {
    if (this.isMetro()) {
      AppStorage.get<RNOHCoreContext>('RNOHCoreContext')?.devToolsController.dismissRNOHErrorDialog()
    }
  }

  private showFailureDialog(): void {
    if (this.isMetro() || !this.mounted || !this.active || !this.failed || this.leaving ||
      this.errorDialog !== undefined) {
      return
    }
    const data: QuecRNErrorDialogData = { onBack: () => this.returnFromError() }
    const dialog = QuecDialog.showCenter(
      this.getUIContext(),
      wrapBuilder<[QuecDialogContent<QuecRNErrorDialogData>]>(buildQuecRNErrorDialog), data, {
      maxWidth: 320,
      closeOnMask: false,
      closeOnBack: false,
      onWillDismiss: (action: DismissDialogAction) => {
        if (action.reason === DismissReason.PRESS_BACK) {
          this.returnFromError()
        }
      }
    })
    this.errorDialog = dialog
    dialog.closed.then(() => {
      if (this.errorDialog === dialog) {
        this.errorDialog = undefined
      }
    })
    dialog.ready.catch((error: Error) => {
      QLog.e('QuecRNView', error)
      if (this.mounted && this.active && !this.leaving) {
        this.leaving = true
        this.onBack()
      }
    })
  }

  private async closeFailureDialog(): Promise<void> {
    const dialog = this.errorDialog
    if (dialog !== undefined) {
      await dialog.close()
      if (this.errorDialog === dialog) {
        this.errorDialog = undefined
      }
    }
  }

  private async returnFromError(): Promise<void> {
    if (!this.mounted || !this.active || this.leaving) {
      return
    }
    this.leaving = true
    try {
      await this.closeFailureDialog()
      if (this.mounted && this.active) {
        this.onBack()
      } else {
        this.leaving = false
      }
    } catch (error) {
      this.leaving = false
      QLog.e('QuecRNView', error instanceof Error ? error : 'Failed to close the panel failure dialog')
    }
  }

  build() {
    Stack() {
      if (this.isMetroDebug() && this.active) {
        RNOHErrorDialog({})
      }
      if (this.renderContext !== undefined) {
        RNSurface({
          ctx: this.renderContext.context,
          surfaceConfig: { surfaceHandle: this.renderContext.surface }
        })
          .width('100%')
          .height('100%')
          .onAppear(() => {
            this.surfaceMounted = true
            this.controller.attachSurface(this.getUIContext())
          })
          .onDisAppear(() => {
            this.surfaceMounted = false
            this.controller.detachSurface()
            this.onSurfaceDetached?.()
            this.onSurfaceDetached = undefined
          })
      } else if (!this.failed) {
        Text($r('app.string.Loading'))
          .fontSize(14)
          .fontColor($r('app.color.W3'))
      }
      if (this.isMetroDebug() && this.active) {
        Column() {
          RNDevLoadingView({
            ctx: AppStorage.get<RNOHCoreContext>('RNOHCoreContext')!,
            useSafeAreaInsets: true
          })
            .width('100%')
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(1)
        .hitTestBehavior(HitTestMode.None)
        .onAppear(() => {
          this.devLoadingMounted = true
          this.updateActive()
        })
        .onDisAppear(() => {
          this.devLoadingMounted = false
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.controller.updateLayout(Number(newArea.width), Number(newArea.height),
        Number(newArea.globalPosition.x), Number(newArea.globalPosition.y))
    })
  }
}
