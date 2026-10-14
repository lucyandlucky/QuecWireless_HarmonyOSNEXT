import { describe, expect, it } from '@ohos/hypium'
import { QuecOemAppConfig } from '../main/ets/core/QuecOemAppConfig'
import { QuecOemConfigManager } from '../main/ets/core/QuecOemConfigManager'

const FULL_YAML: string = [
  "configId: '271'",
  'version: 1.0.0',
  'platform: android',
  'basic:',
  '  bundleId: com.quectel.ioe',
  '  appVersion: 3.0.0',
  '  appVersionCode: 1',
  '  area: china',
  "  appTypeId: '1'",
  '  appName:',
  '    cn: 测试',
  'network:',
  '  china:',
  '    baseUrl: https://cn.example.com',
  '    userDomain: C.DM.1',
  '    userDomainSecret: secret',
  '  europe:',
  '    baseUrl: https://eu.example.com',
  '    userDomain: null',
  'business:',
  "  isChina: 'true'"
].join('\n')

export default function quecOemConfigManagerTest(): void {
  describe('QuecOemConfigManager', () => {
    it('converts top-level and basic values with Android types', 0, () => {
      QuecOemConfigManager.parseConfigContent(FULL_YAML)
      expect(QuecOemAppConfig.configId).assertEqual(271)
      expect(QuecOemAppConfig.version).assertEqual('1.0.0')
      expect(QuecOemAppConfig.platform).assertEqual('android')
      expect(QuecOemAppConfig.basic.area).assertEqual('china')
      expect(QuecOemAppConfig.basic.appVersion).assertEqual('3.0.0')
      expect(QuecOemAppConfig.basic.appVersionCode).assertEqual('1')
      expect(QuecOemAppConfig.basic.appTypeId).assertEqual(1)
      expect(QuecOemAppConfig.basic.appName.cn).assertEqual('测试')
      expect(QuecOemAppConfig.basic.appName.en).assertEqual('QuecOne')
    })

    it('reads network configs per region with defaults for missing values', 0, () => {
      QuecOemConfigManager.parseConfigContent(FULL_YAML)
      expect(QuecOemAppConfig.network.china.baseUrl).assertEqual('https://cn.example.com')
      expect(QuecOemAppConfig.network.china.userDomain).assertEqual('C.DM.1')
      expect(QuecOemAppConfig.network.china.userDomainSecret).assertEqual('secret')
      expect(QuecOemAppConfig.network.china.webSocketUrl).assertEqual('')
      expect(QuecOemAppConfig.network.europe.baseUrl).assertEqual('https://eu.example.com')
      expect(QuecOemAppConfig.network.europe.userDomain).assertEqual('')
      expect(QuecOemAppConfig.network.northAmerica.baseUrl).assertEqual('')
    })

    it('falls back to Android defaults when sections are missing', 0, () => {
      QuecOemConfigManager.parseConfigContent('version: 2.0.0')
      expect(QuecOemAppConfig.configId).assertEqual(111)
      expect(QuecOemAppConfig.version).assertEqual('2.0.0')
      expect(QuecOemAppConfig.platform).assertEqual('android')
      expect(QuecOemAppConfig.basic.area).assertEqual('')
      expect(QuecOemAppConfig.basic.appTypeId).assertEqual(-1)
      expect(QuecOemAppConfig.network.china.baseUrl).assertEqual('')
    })

    it('keeps the current config when YAML is not a mapping', 0, () => {
      QuecOemConfigManager.parseConfigContent(FULL_YAML)
      let failed: boolean = false
      try {
        QuecOemConfigManager.parseConfigContent('- just\n- a list')
      } catch (error) {
        failed = true
      }
      expect(failed).assertTrue()
      expect(QuecOemAppConfig.configId).assertEqual(271)
    })
  })
}
