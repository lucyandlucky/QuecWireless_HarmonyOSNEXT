import quecNetworkV2Test from './QuecNetworkV2.test'
import quecRequestHeaderInterceptorTest from './QuecRequestHeaderInterceptor.test'

export default function testsuite(): void {
  quecNetworkV2Test()
  quecRequestHeaderInterceptorTest()
}
