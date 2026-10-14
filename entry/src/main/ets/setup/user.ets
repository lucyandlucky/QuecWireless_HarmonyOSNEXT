import { QuecGlobalConfig, QuecOemNetworkConfigModel } from '@quec/oem-app-config'
import { QuecUserSdkConfig, QuecUserService } from '@quec/user-sdk'

export function setupUserSdk(): void {
  const network: QuecOemNetworkConfigModel = QuecGlobalConfig.network
  QuecUserService.init(new QuecUserSdkConfig(network.userDomain, network.userDomainSecret))
}
