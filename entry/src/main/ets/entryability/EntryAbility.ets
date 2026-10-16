import { AbilityConstant, Want } from '@kit.AbilityKit';
import { HMRouterMgr } from '@hadss/hmrouter';
import { QLog } from '@quec/log';
import { RNAbility } from '@rnoh/react-native-openharmony';

export default class EntryAbility extends RNAbility {
  protected getPagePath(): string {
    return 'pages/AppRoot'
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onCreate(want, launchParam)
    HMRouterMgr.init({
      context: this.context
    })
  }

  onBackground(): void {
    super.onBackground()
    QLog.flush()
  }
}
