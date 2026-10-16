import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { QuecDialogResolvedOptions } from './QuecDialogConfig'
import { buildQuecDialogHost, QuecDialogHostParams } from './QuecDialogHost'
import { QuecDialogContent, QuecDialogHandle } from './QuecDialogTypes'

/** A single instance owns its UIContext and native content until close succeeds. */
export class QuecDialogCore<T extends Object> implements QuecDialogHandle<T> {
  readonly ready: Promise<void>
  readonly closed: Promise<void>
  private resolveClosed: () => void = () => {}
  private componentContent: ComponentContent<QuecDialogHostParams<T>> | undefined = undefined
  private closePromise: Promise<void> | undefined = undefined
  private closeRequested: boolean = false
  private disposed: boolean = false
  private readonly closeContent: () => Promise<void> = () => this.close()
  private readonly uiContext: UIContext
  private readonly builder: WrappedBuilder<[QuecDialogContent<T>]>
  private data: T
  private readonly options: QuecDialogResolvedOptions

  constructor(
    uiContext: UIContext,
    builder: WrappedBuilder<[QuecDialogContent<T>]>,
    data: T,
    options: QuecDialogResolvedOptions
  ) {
    this.uiContext = uiContext
    this.builder = builder
    this.data = data
    this.options = options
    this.closed = new Promise<void>((resolve) => {
      this.resolveClosed = resolve
    })
    // A microtask lets the caller retain the handle before a Builder can request close.
    this.ready = Promise.resolve().then(() => this.open())
    // Keep optional ready consumers from causing an unhandled rejection.
    this.ready.catch(() => {})
  }

  update(data: T): void {
    if (this.disposed || this.closePromise !== undefined) {
      return
    }
    this.data = data
    this.componentContent?.update(this.createHostParams())
  }

  close(): Promise<void> {
    if (this.disposed) {
      return Promise.resolve()
    }
    if (this.closePromise === undefined) {
      this.closeRequested = true
      this.closePromise = this.closeAfterReady()
    }
    return this.closePromise
  }

  private createHostParams(): QuecDialogHostParams<T> {
    return {
      builder: this.builder,
      content: { data: this.data, close: this.closeContent },
      options: this.options
    }
  }

  private async open(): Promise<void> {
    if (this.closeRequested) {
      this.finish()
      return
    }
    try {
      this.clearPageFocusIfNeeded()
      this.componentContent = new ComponentContent(
        this.uiContext,
        wrapBuilder<[QuecDialogHostParams<T>]>(buildQuecDialogHost),
        this.createHostParams(),
        { nestingBuilderSupported: true }
      )
      const nativeOptions: promptAction.BaseDialogOptions = {
        alignment: this.options.placement === 'bottom' ? DialogAlignment.Bottom : DialogAlignment.Center,
        offset: { dx: 0, dy: 0 },
        autoCancel: this.options.closeOnMask,
        maskColor: this.options.maskColor,
        keyboardAvoidMode: this.options.keyboardAvoidMode,
        transition: this.options.transition,
        dialogTransition: this.options.dialogTransition,
        maskTransition: this.options.maskTransition,
        onWillDismiss: (action: DismissDialogAction) => this.onWillDismiss(action),
        onDidDisappear: () => this.finish()
      }
      await this.uiContext.getPromptAction().openCustomDialog(this.componentContent, nativeOptions)
    } catch (error) {
      // A newly constructed content whose open failed is not mounted.
      this.finish()
      throw (error as Error)
    }
  }

  private clearPageFocusIfNeeded(): void {
    if (!this.options.dismissKeyboardOnOpen) {
      return
    }
    try {
      // Clearing the page focus dismisses a focused TextInput and lets the IME
      // close before the bottom sheet performs its first layout pass.
      this.uiContext.getFocusController().clearFocus()
    } catch (error) {
      console.error(`[QuecDialog] Clear page focus failed: ${(error as Error).message}`)
    }
  }

  private async closeAfterReady(): Promise<void> {
    try {
      await this.ready
    } catch (_error) {
      // The failed open already released the content.
      return
    }
    if (this.disposed || this.componentContent === undefined) {
      return
    }
    try {
      await this.uiContext.getPromptAction().closeCustomDialog(this.componentContent)
      // Also handles interrupted exit animations, which omit onDidDisappear.
      this.finish()
    } catch (error) {
      if (this.disposed || (error as BusinessError).code === 103303) {
        // 103303 explicitly means the native dialog is no longer present.
        this.finish()
        return
      }
      // Preserve mounted content and allow a later close attempt.
      this.closePromise = undefined
      this.closeRequested = false
      throw (error as Error)
    }
  }

  private onWillDismiss(action: DismissDialogAction): void {
    const override = this.options.onWillDismiss
    if (override !== undefined) {
      try {
        override({
          reason: action.reason,
          dismiss: () => this.closeFromInteraction()
        })
      } catch (error) {
        console.error(`[QuecDialog] onWillDismiss failed: ${(error as Error).message}`)
      }
      return
    }
    if ((action.reason === DismissReason.TOUCH_OUTSIDE && this.options.closeOnMask) ||
      (action.reason === DismissReason.PRESS_BACK && this.options.closeOnBack)) {
      this.closeFromInteraction()
    }
  }

  private closeFromInteraction(): void {
    this.close().catch((error: Error) => {
      console.error(`[QuecDialog] Close failed: ${error.message}`)
    })
  }

  private finish(): void {
    if (this.disposed) {
      return
    }
    this.disposed = true
    const content = this.componentContent
    this.componentContent = undefined
    try {
      content?.dispose()
    } catch (error) {
      console.error(`[QuecDialog] Dispose failed: ${(error as Error).message}`)
    }
    this.resolveClosed()
    try {
      this.options.onClosed?.()
    } catch (error) {
      console.error(`[QuecDialog] onClosed failed: ${(error as Error).message}`)
    }
  }
}
