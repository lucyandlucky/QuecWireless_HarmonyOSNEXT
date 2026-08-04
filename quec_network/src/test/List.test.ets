import quecHeaderProviderTest from './QuecHeaderProvider.test'
import quecResponseParserTest from './QuecResponseParser.test'

export default function testsuite(): void {
  quecResponseParserTest()
  quecHeaderProviderTest()
}
