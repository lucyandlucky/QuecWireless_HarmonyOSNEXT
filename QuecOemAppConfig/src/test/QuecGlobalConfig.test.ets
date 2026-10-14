import { describe, expect, it } from '@ohos/hypium'
import { QuecGlobalConfig } from '../main/ets/core/QuecGlobalConfig'
import { QuecOemConfigManager } from '../main/ets/core/QuecOemConfigManager'
import { QuecOemAppConfig } from '../main/ets/core/QuecOemAppConfig'
import { QuecRegion } from '../main/ets/model/QuecRegion'

function yamlWithArea(area: string): string {
  return [
    'basic:',
    `  area: ${area}`,
    'network:',
    '  china:',
    '    baseUrl: https://cn.example.com',
    '    userDomain: C.DM.1',
    '  europe:',
    '    baseUrl: https://eu.example.com',
    '    userDomain: E.SP.1',
    '  northAmerica:',
    '    baseUrl: https://us.example.com',
    '    userDomain: U.SP.1'
  ].join('\n')
}

export default function quecGlobalConfigTest(): void {
  describe('QuecGlobalConfig', () => {
    it('resolves the region in the same order as Android', 0, () => {
      // area 为 china 时忽略已保存的选择
      expect(QuecGlobalConfig.resolve('china', QuecRegion.NORTH_AMERICA)).assertEqual(QuecRegion.CHINA)
      expect(QuecGlobalConfig.resolve('china', QuecRegion.EUROPE)).assertEqual(QuecRegion.CHINA)
      // 已保存的选择优先，北美先于欧洲
      expect(QuecGlobalConfig.resolve('europe', QuecRegion.NORTH_AMERICA)).assertEqual(QuecRegion.NORTH_AMERICA)
      expect(QuecGlobalConfig.resolve('usa', QuecRegion.EUROPE)).assertEqual(QuecRegion.EUROPE)
      // saved 为默认值 0 时按 area 兜底
      expect(QuecGlobalConfig.resolve('europe', QuecRegion.CHINA)).assertEqual(QuecRegion.EUROPE)
      expect(QuecGlobalConfig.resolve('usa', QuecRegion.CHINA)).assertEqual(QuecRegion.NORTH_AMERICA)
      // 配置解析失败时 area 为空，与 Android 一样落到北美
      expect(QuecGlobalConfig.resolve('', QuecRegion.CHINA)).assertEqual(QuecRegion.NORTH_AMERICA)
    })

    it('exposes the network config of the current region', 0, () => {
      // 本地单测里 MMKV 未初始化，readSaved 退回 0，所以结果由 area 决定。
      QuecOemConfigManager.parseConfigContent(yamlWithArea('china'))
      QuecGlobalConfig.init()
      expect(QuecGlobalConfig.region).assertEqual(QuecRegion.CHINA)
      expect(QuecGlobalConfig.network.baseUrl).assertEqual('https://cn.example.com')
      expect(QuecGlobalConfig.network.userDomain).assertEqual('C.DM.1')

      QuecOemConfigManager.parseConfigContent(yamlWithArea('europe'))
      QuecGlobalConfig.init()
      expect(QuecGlobalConfig.region).assertEqual(QuecRegion.EUROPE)
      expect(QuecGlobalConfig.network.baseUrl).assertEqual('https://eu.example.com')

      QuecOemConfigManager.parseConfigContent(yamlWithArea('usa'))
      QuecGlobalConfig.init()
      expect(QuecGlobalConfig.region).assertEqual(QuecRegion.NORTH_AMERICA)
      expect(QuecGlobalConfig.network.baseUrl).assertEqual('https://us.example.com')
    })

    it('reads through to QuecOemAppConfig instead of copying', 0, () => {
      QuecOemConfigManager.parseConfigContent(yamlWithArea('europe'))
      QuecGlobalConfig.init()
      expect(QuecGlobalConfig.network.baseUrl).assertEqual('https://eu.example.com')

      // 重新解析会新建 network 对象，getter 必须拿到新的那一份
      QuecOemConfigManager.parseConfigContent([
        'basic:',
        '  area: europe',
        'network:',
        '  europe:',
        '    baseUrl: https://eu2.example.com'
      ].join('\n'))
      expect(QuecGlobalConfig.network.baseUrl).assertEqual('https://eu2.example.com')
      expect(QuecGlobalConfig.network === QuecOemAppConfig.network.europe).assertTrue()
    })

    it('forwards the fields that do not depend on the region', 0, () => {
      QuecOemConfigManager.parseConfigContent([
        "configId: '271'",
        'version: 1.0.0',
        'platform: android',
        'basic:',
        '  area: china',
        '  appVersion: 3.0.0',
        '  appName:',
        '    cn: 移联万物'
      ].join('\n'))
      QuecGlobalConfig.init()
      expect(QuecGlobalConfig.configId).assertEqual(271)
      expect(QuecGlobalConfig.version).assertEqual('1.0.0')
      expect(QuecGlobalConfig.platform).assertEqual('android')
      expect(QuecGlobalConfig.basic.appVersion).assertEqual('3.0.0')
      expect(QuecGlobalConfig.basic.appName.cn).assertEqual('移联万物')
      expect(QuecGlobalConfig.basic === QuecOemAppConfig.basic).assertTrue()
    })
  })
}
