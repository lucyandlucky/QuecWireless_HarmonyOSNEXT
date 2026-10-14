import quecHeaderProviderTest from './QuecHeaderProvider.test'
import quecNetworkTest from './QuecNetwork.test'
import quecResponseParserTest from './QuecResponseParser.test'

export default function testsuite(): void {
  quecResponseParserTest()
  quecHeaderProviderTest()
  quecNetworkTest()
}
