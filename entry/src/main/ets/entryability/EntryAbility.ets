import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getWindowInsetsState, WindowInsetsState } from 'quec_basic_ui';
import { setupNetwork } from '../network/NetworkBootstrap';
import { QuecMmkvManager } from 'quec_mmkv';
import { HMRouterMgr } from '@hadss/hmrouter';

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
      const systemArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      const navigationArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      this.windowInsets.top = uiContext.px2vp(systemArea.topRect.height)
      this.windowInsets.bottom = uiContext.px2vp(navigationArea.bottomRect.height)

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
    HMRouterMgr.init({
      context: this.context
    })
    const applicationContext = this.context.getApplicationContext()
    QuecMmkvManager.initialize(applicationContext)
    setupNetwork()
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
