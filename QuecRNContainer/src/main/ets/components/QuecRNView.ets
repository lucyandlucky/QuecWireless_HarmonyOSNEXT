import { QLog } from '@quec/log'
import { RNSurface } from '@rnoh/react-native-openharmony'

import { QuecRNLoadInfo } from '../model/QuecRNLoadInfo'
import { QuecRNController, QuecRNRenderContext } from '../runtime/QuecRNController'

@ComponentV2
export struct QuecRNView {
  @Require @Param info: QuecRNLoadInfo
  @Require @Param controller: QuecRNController
  @Param active: boolean = true
  @Event onBack: () => void = () => {
  }
  @Local private renderContext: QuecRNRenderContext | undefined = undefined
  @Local private failed: boolean = false
  private mounted: boolean = false

  aboutToAppear(): void {
    this.mounted = true
    this.updateActive()
  }

  @Monitor('active')
  private updateActive(): void {
    this.controller.setActive(this.active)
    if (this.mounted && this.active && this.renderContext === undefined && !this.failed) {
      this.load()
    }
  }

  private async load(): Promise<void> {
    try {
      const context = await this.controller.load(this.info, () => this.onBack())
      if (this.mounted) {
        this.renderContext = context
      }
    } catch (error) {
      if (this.mounted) {
        this.failed = true
        const message = error instanceof Error ? error.message : 'Unknown error'
        QLog.e('QuecRNView', `failed to load bundle '${this.info.bundleId}': ${message}`)
      }
    }
  }

  aboutToDisappear(): void {
    this.mounted = false
    this.controller.dispose().catch(() => QLog.e('QuecRNView', 'failed to release the RN container'))
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
      } else if (this.failed) {
        Text('RN 页面加载失败')
          .fontSize(14)
          .fontColor($r('app.color.W3'))
      } else {
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
