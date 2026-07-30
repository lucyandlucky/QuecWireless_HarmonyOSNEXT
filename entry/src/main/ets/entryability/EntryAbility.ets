import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getWindowInsetsState, WindowInsetsState } from 'quec_basic_ui';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private windowInsets: WindowInsetsState = getWindowInsetsState()

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {

    let windowClass = windowStage.getMainWindowSync()
    windowClass.setWindowLayoutFullScreen(true).then(() => {
      const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      console.log('avoidArea.topRect.height', avoidArea.topRect.height)
      this.windowInsets.top = avoidArea.topRect.height
    }).catch()

    windowStage.loadContent('pages/AppRoot', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });


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