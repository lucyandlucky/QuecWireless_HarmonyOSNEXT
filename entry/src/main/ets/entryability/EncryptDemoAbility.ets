import { UIAbility } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'

const DOMAIN: number = 0x0000
const TAG: string = 'EncryptDemoAbility'

export default class EncryptDemoAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/QuecEncryptDemoPage', (error) => {
      if (error.code) {
        hilog.error(
          DOMAIN,
          TAG,
          'Failed to load QuecEncryptDemoPage. code: %{public}d, message: %{public}s',
          error.code,
          error.message
        )
      }
    })
  }
}
