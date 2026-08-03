import { describe, expect, it } from '@ohos/hypium'
import { QuecNetworkConstants } from '../main/ets/constants/QuecNetworkConstants'
import { QuecNetworkError, QuecNetworkErrorType } from '../main/ets/error/QuecNetworkError'
import { QuecRawResponse } from '../main/ets/model/QuecRawResponse'
import { QuecResponseParser } from '../main/ets/parser/QuecResponseParser'

interface TestPayload {
  name: string
}

class TestHeaders {
}

function createResponse(statusCode: number, body: string): QuecRawResponse {
  return {
    statusCode: statusCode,
    body: body,
    headers: new TestHeaders()
  }
}

function assertNetworkError(
  action: () => void,
  expectedType: QuecNetworkErrorType,
  expectedCode: number,
  expectedSubCode: number = QuecNetworkConstants.DEFAULT_SUB_CODE
): void {
  let thrown: boolean = false

  try {
    action()
  } catch (error) {
    thrown = true
    const networkError: QuecNetworkError = error as QuecNetworkError
    expect(networkError.type).assertEqual(expectedType)
    expect(networkError.code).assertEqual(expectedCode)
    expect(networkError.subCode).assertEqual(expectedSubCode)
  }

  expect(thrown).assertTrue()
}

export default function quecResponseParserTest(): void {
  const parser: QuecResponseParser = new QuecResponseParser()

  describe('QuecResponseParser', () => {
    it('should parse data when HTTP and business codes succeed', 0, () => {
      const response: QuecRawResponse = createResponse(
        200,
        '{"code":200,"msg":"success","data":{"name":"QuecWireless"}}'
      )

      const result: TestPayload = parser.parse<TestPayload>(response)

      expect(result.name).assertEqual('QuecWireless')
    })

    it('should accept HTTP status 299', 0, () => {
      const response: QuecRawResponse = createResponse(
        299,
        '{"code":200,"data":{"name":"Boundary"}}'
      )

      const result: TestPayload = parser.parse<TestPayload>(response)

      expect(result.name).assertEqual('Boundary')
    })

    it('should reject HTTP status below 200', 0, () => {
      const response: QuecRawResponse = createResponse(199, '{}')

      assertNetworkError(
        () => {
          parser.parse<TestPayload>(response)
        },
        QuecNetworkErrorType.HTTP_ERROR,
        199
      )
    })

    it('should reject HTTP status above 299', 0, () => {
      const response: QuecRawResponse = createResponse(300, '{}')

      assertNetworkError(
        () => {
          parser.parse<TestPayload>(response)
        },
        QuecNetworkErrorType.HTTP_ERROR,
        300
      )
    })

    it('should preserve business error code and subCode', 0, () => {
      const response: QuecRawResponse = createResponse(
        200,
        '{"code":5032,"msg":"token invalid","subCode":1001}'
      )

      assertNetworkError(
        () => {
          parser.parse<TestPayload>(response)
        },
        QuecNetworkErrorType.COMMON,
        5032,
        1001
      )
    })

    it('should reject null response data', 0, () => {
      const response: QuecRawResponse = createResponse(
        200,
        '{"code":200,"data":null}'
      )

      assertNetworkError(
        () => {
          parser.parse<TestPayload>(response)
        },
        QuecNetworkErrorType.DATA_NULL,
        200
      )
    })

    it('should reject missing response data', 0, () => {
      const response: QuecRawResponse = createResponse(200, '{"code":200}')

      assertNetworkError(
        () => {
          parser.parse<TestPayload>(response)
        },
        QuecNetworkErrorType.DATA_NULL,
        200
      )
    })

    it('should reject invalid JSON', 0, () => {
      const response: QuecRawResponse = createResponse(200, '{invalid json}')

      assertNetworkError(
        () => {
          parser.parse<TestPayload>(response)
        },
        QuecNetworkErrorType.PARSE_ERROR,
        QuecNetworkConstants.UNKNOWN_ERROR_CODE
      )
    })

    it('should reject a null JSON response body', 0, () => {
      const response: QuecRawResponse = createResponse(200, 'null')

      assertNetworkError(
        () => {
          parser.parse<TestPayload>(response)
        },
        QuecNetworkErrorType.PARSE_ERROR,
        QuecNetworkConstants.UNKNOWN_ERROR_CODE
      )
    })

    it('should reject response without a numeric business code', 0, () => {
      const response: QuecRawResponse = createResponse(
        200,
        '{"code":"200","data":{"name":"InvalidCode"}}'
      )

      assertNetworkError(
        () => {
          parser.parse<TestPayload>(response)
        },
        QuecNetworkErrorType.PARSE_ERROR,
        QuecNetworkConstants.UNKNOWN_ERROR_CODE
      )
    })

    it('should parse successful response without data', 0, () => {
      const response: QuecRawResponse = createResponse(200, '{"code":200}')

      parser.parseWithoutData(response)

      expect(true).assertTrue()
    })

    it('should reject business error without data', 0, () => {
      const response: QuecRawResponse = createResponse(
        200,
        '{"code":5106,"msg":"token missing"}'
      )

      assertNetworkError(
        () => {
          parser.parseWithoutData(response)
        },
        QuecNetworkErrorType.COMMON,
        5106
      )
    })
  })
}
