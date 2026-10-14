import quecGlobalConfigTest from './QuecGlobalConfig.test'
import quecOemConfigManagerTest from './QuecOemConfigManager.test'

export default function testsuite(): void {
  quecGlobalConfigTest()
  quecOemConfigManagerTest()
}
