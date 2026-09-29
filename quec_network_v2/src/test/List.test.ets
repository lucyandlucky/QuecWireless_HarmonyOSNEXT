import quecNetworkV2Test from './QuecNetworkV2.test'
import quecNetworkV2RequestTest from './QuecNetworkV2Request.test'
import quecRequestHeaderInterceptorTest from './QuecRequestHeaderInterceptor.test'
import quecResponseDataInterceptorTest from './QuecResponseDataInterceptor.test'
import quecHttpLogInterceptorTest from './QuecHttpLogInterceptor.test'

export default function testsuite(): void {
  quecNetworkV2RequestTest()
  quecNetworkV2Test()
  quecRequestHeaderInterceptorTest()
  quecResponseDataInterceptorTest()
  quecHttpLogInterceptorTest()
}
