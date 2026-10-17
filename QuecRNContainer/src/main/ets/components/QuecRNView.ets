import { QuecDialog, QuecDialogContent, QuecDialogHandle } from '@quec/basic-ui'
import { QLog } from '@quec/log'
import { RNSurface } from '@rnoh/react-native-openharmony'

import { QuecRNError } from '../model/QuecRNError'
import { QuecRNLoadInfo } from '../model/QuecRNLoadInfo'
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
  private errorDialog: QuecDialogHandle<QuecRNErrorDialogData> | undefined = undefined

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
      this.closeFailureDialog()
        .then(() => this.showFailureDialog())
        .catch((error: Error) => QLog.e('QuecRNView', error))
    } else if (this.failed) {
      this.showFailureDialog()
    } else if (this.renderContext === undefined) {
      this.load()
    }
  }

  private async load(): Promise<void> {
    try {
      const context = await this.controller.load(this.info, () => this.onBack(), (error: QuecRNError) => {
        if (this.mounted) {
          this.failed = true
          this.showFailureDialog()
          this.onError(error)
        }
      })
      if (this.mounted) {
        this.renderContext = context
      }
    } catch (error) {
      if (this.mounted) {
        this.failed = true
        const message = error instanceof Error ? error.message : 'Unknown error'
        QLog.e('QuecRNView', `failed to load bundle '${this.info.bundleId}': ${message}`)
        if (error instanceof Error && error.stack) {
          QLog.e('QuecRNView', error.stack)
        }
        this.showFailureDialog()
      }
    }
  }

  aboutToDisappear(): void {
    this.mounted = false
    this.closeFailureDialog().catch((error: Error) => QLog.e('QuecRNView', error))
    this.controller.dispose().catch(() => QLog.e('QuecRNView', 'failed to release the RN container'))
  }

  private showFailureDialog(): void {
    if (!this.mounted || !this.active || !this.failed || this.leaving || this.errorDialog !== undefined) {
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
      if (this.renderContext !== undefined) {
        RNSurface({
          ctx: this.renderContext.context,
          surfaceConfig: { surfaceHandle: this.renderContext.surface }
        })
          .width('100%')
          .height('100%')
          .onAppear(() => this.controller.attachSurface(this.getUIContext()))
      } else if (!this.failed) {
        Text($r('app.string.Loading'))
          .fontSize(14)
          .fontColor($r('app.color.W3'))
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
