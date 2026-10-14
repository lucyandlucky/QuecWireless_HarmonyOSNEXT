import { AbilityStage, common } from '@kit.AbilityKit';
import { QLog } from '@quec/log';
import { QuecMmkvManager } from '@quec/mmkv';
import { QuecOemConfigManager, QuecGlobalConfig } from '@quec/oem-app-config';

import { setupNetwork } from '../setup/network';
import { setupUserSdk } from '../setup/user';

const TAG: string = 'QuecAbilityStage'

export default class QuecAbilityStage extends AbilityStage {
  onCreate(): void {
    const applicationContext: common.ApplicationContext = this.context.getApplicationContext()
    QuecMmkvManager.init(applicationContext)
    QLog.init(applicationContext)
    QLog.i(TAG, 'onCreate')
    QuecOemConfigManager.init(applicationContext)
    QuecGlobalConfig.init()
    setupNetwork()
    setupUserSdk()
  }

  onDestroy(): void {
    QLog.close()
  }
}
