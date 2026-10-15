import { HMParamType, HMRouterMgr } from '@hadss/hmrouter'
import { QuecUserService } from '@quec/user-sdk'

import { PersonalCenterUiState } from '../state/PersonalCenterUiState'

export class PersonalCenterRouteParams {
  state: PersonalCenterUiState

  constructor(state: PersonalCenterUiState) {
    this.state = state
  }
}

export function getPersonalCenterRouteState(): PersonalCenterUiState {
  const params = HMRouterMgr.getCurrentParam(HMParamType.routeParam) as PersonalCenterRouteParams | null
  if (params?.state !== undefined) {
    return params.state
  }
  const state: PersonalCenterUiState = new PersonalCenterUiState()
  state.user = QuecUserService.getUserModel()
  return state
}
