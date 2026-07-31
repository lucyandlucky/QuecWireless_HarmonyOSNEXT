import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getWindowInsetsState, WindowInsetsState } from 'quec_basic_ui';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private windowInsets: WindowInsetsState = getWindowInsetsState()

  private async initializeWindow(windowStage: window.WindowStage): Promise<void> {
    try {
      const windowClass = windowStage.getMainWindowSync()
      await windowClass.setWindowLayoutFullScreen(true)
      windowStage.loadContent('pages/AppRoot', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        this.updateWindowInsets(windowClass)
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
    } catch (error) {
      const businessError = error as BusinessError
      hilog.error(
        DOMAIN,
        'WindowInsets',
        'Failed to initialize window. code: %{public}d, message: %{public}s',
        businessError.code,
        businessError.message
      )
    }
  }

  private updateWindowInsets(windowClass: window.Window): void {
    try {
      const uiContext = windowClass.getUIContext()
      const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      this.windowInsets.top = uiContext.px2vp(avoidArea.topRect.height)

    } catch (error) {
      const businessError = error as BusinessError
      hilog.error(
        DOMAIN,
        'WindowInsets',
        'Failed to update window insets. code: %{public}d, message: %{public}s',
        businessError.code,
        businessError.message
      )
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.initializeWindow(windowStage)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
  }

  onForeground(): void {
    // Ability has brought to foreground
  }

  onBackground(): void {
    // Ability has back to background
  }
}