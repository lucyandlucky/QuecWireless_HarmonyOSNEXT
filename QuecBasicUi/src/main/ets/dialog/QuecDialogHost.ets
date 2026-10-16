import { window } from '@kit.ArkUI'
import { QuecDialogResolvedOptions } from './QuecDialogConfig'
import { QuecDialogContent } from './QuecDialogTypes'

export interface QuecDialogHostParams<T extends Object> {
  builder: WrappedBuilder<[QuecDialogContent<T>]>
  content: QuecDialogContent<T>
  options: QuecDialogResolvedOptions
}

/** Only the shell belongs here. Pages own padding, scrolling and all business UI. */
@ComponentV2
struct QuecDialogHost {
  // ComponentContent.update replaces this one object, so the content Builder is
  // invoked by the ArkUI component itself and receives the correct View context.
  @Param params: QuecDialogHostParams<Object> | undefined = undefined
  @Local private bottomInset: number = 0
  @Local private keyboardVisible: boolean = false
  private ownerWindow: window.Window | undefined = undefined
  private readonly onAvoidAreaChange: Callback<window.AvoidAreaOptions> = (event) => {
    if (event.type === window.AvoidAreaType.TYPE_KEYBOARD) {
      this.keyboardVisible = this.hasAvoidArea(event.area)
      if (this.keyboardVisible) {
        // BaseDialogOptions.keyboardAvoidMode already lets the system position
        // the sheet above the IME. Do not add the navigation inset a second time.
        this.bottomInset = 0
      } else {
        this.refreshNavigationInset()
      }
      return
    }
    if (event.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      if (!this.keyboardVisible) {
        this.bottomInset = this.getUIContext().px2vp(event.area.bottomRect.height)
      }
    }
  }

  private hasAvoidArea(area: window.AvoidArea): boolean {
    return area.bottomRect.height > 0 || area.topRect.height > 0 ||
      area.leftRect.width > 0 || area.rightRect.width > 0
  }

  private refreshNavigationInset(): void {
    try {
      if (this.ownerWindow === undefined) {
        return
      }
      const area = this.ownerWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      this.bottomInset = this.getUIContext().px2vp(area.bottomRect.height)
    } catch (error) {
      console.error(`[QuecDialog] Read bottom inset failed: ${(error as Error).message}`)
    }
  }

  aboutToAppear(): void {
    if (this.params?.options.safeAreaBottom !== true) {
      return
    }
    try {
      const uiContext = this.getUIContext()
      const windowName = uiContext.getWindowName()
      if (windowName === undefined) {
        return
      }
      const ownerWindow = window.findWindow(windowName)
      this.ownerWindow = ownerWindow
      const keyboardArea = ownerWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD)
      this.keyboardVisible = this.hasAvoidArea(keyboardArea)
      if (!this.keyboardVisible) {
        this.refreshNavigationInset()
      }
      ownerWindow.on('avoidAreaChange', this.onAvoidAreaChange)
    } catch (error) {
      console.error(`[QuecDialog] Read bottom inset failed: ${(error as Error).message}`)
    }
  }

  aboutToDisappear(): void {
    try {
      this.ownerWindow?.off('avoidAreaChange', this.onAvoidAreaChange)
    } catch (error) {
      console.error(`[QuecDialog] Remove inset listener failed: ${(error as Error).message}`)
    }
    this.ownerWindow = undefined
  }

  build() {
    Column() {
      if (this.params !== undefined) {
        this.params.builder.builder(this.params.content)
      }
    }
    .width(this.params?.options.width)
    .height(this.params?.options.height)
    .constraintSize({
      maxWidth: this.params?.options.maxWidth,
      maxHeight: this.params?.options.maxHeight
    })
    .padding({ bottom: this.params?.options.safeAreaBottom ? this.bottomInset : 0 })
    .backgroundColor(this.params?.options.backgroundColor)
    .borderRadius(this.params?.options.cornerRadius)
    .clip(true)
  }
}

@Builder
export function buildQuecDialogHost<T extends Object>(params: QuecDialogHostParams<T>) {
  QuecDialogHost({
    params: params as Object as QuecDialogHostParams<Object>
  })
}
