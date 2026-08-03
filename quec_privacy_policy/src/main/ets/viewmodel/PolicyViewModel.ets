import { PolicyRouteParams, PolicySource } from '../model/PolicyRoute';
import { PolicyUiState } from '../state/PolicyUiState';

export class PolicyViewModel {
  readonly state: PolicyUiState = new PolicyUiState()
  private initialized: boolean = false

  initialize(params: PolicyRouteParams): void {
    if (this.initialized) {
      return
    }
    this.initialized = true
    this.state.title = params.title
    this.state.pdfUrl = params.downloadUrl ?? ''
    this.state.webError = false
    this.state.errorMessage = ''

    const url = params.url?.trim() ?? ''

    if (params.source !== PolicySource.DIRECT_URL || url.length === 0) {
      this.state.webError = true
      this.state.errorMessage = 'Invalid policy route parameters'
      return
    }

    this.state.htmlUrl = url
  }

  onWebLoadStart(): void {
    this.state.webLoading = true
    this.state.webError = false
    this.state.errorMessage = ''
  }

  onWebLoadingFinish(): void {
    this.state.webLoading = false
  }

  onWebLoadError(msg: string): void {
    this.state.webLoading = false
    this.state.webError = true
    this.state.errorMessage = msg
  }

  preparedRetry(): void {
    this.state.webLoading = true
    this.state.webError = false
    this.state.errorMessage = ''
  }
}