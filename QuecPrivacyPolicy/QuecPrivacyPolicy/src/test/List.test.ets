import localUnitTest from './LocalUnit.test';
import policyApiTest from './PolicyApi.test';

export default function testsuite() {
  localUnitTest();
  policyApiTest();
}
