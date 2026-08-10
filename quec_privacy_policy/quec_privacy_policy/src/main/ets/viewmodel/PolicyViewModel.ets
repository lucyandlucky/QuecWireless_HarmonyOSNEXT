import { PolicyDocument } from '../model/PolicyDocument';
import { PolicyRouteParams, PolicySource, PolicyType } from 'quec_privacy_policy_api';
import { PolicyRepository } from '../repository/PolicyRepository';
import { PolicyUiState } from '../state/PolicyUiState';

export class PolicyViewModel {
  readonly state: PolicyUiState = new PolicyUiState()
  private readonly repository: PolicyRepository = new PolicyRepository()
  private initialized: boolean = false
  private latestType: PolicyType | undefined

  public initialize(params: PolicyRouteParams): void {
    if (this.initialized) {
      return
    }
    this.initialized = true
    this.state.title = params.title
    this.state.pdfUrl = params.downloadUrl ?? ''
    this.state.webError = false
    this.state.apiError = false

    if (params.source === PolicySource.DIRECT_URL) {
      this.initDirectUrl(params)
      return
    }

    if (params.type === undefined) {
      this.state.apiError = true
      return
    }

    this.latestType = params.type
    this.loadLatest(params.type)
  }

  public retryLatest(): void {
    const type: PolicyType | undefined = this.latestType
    if (type === undefined) {
      this.state.apiError = true
      return
    }
    this.loadLatest(type)
  }

  private async loadLatest(type: PolicyType): Promise<void> {
    this.state.apiLoading = true
    this.state.apiError = false
    this.state.webError = false
    this.state.webLoading = false
    try {
      const document: PolicyDocument = await this.repository.getLatest(type)
      this.state.htmlUrl = document.htmlUrl
      this.state.pdfUrl = document.pdfUrl
    } catch (error) {
      const source: Error = error
      this.state.htmlUrl = ''
      this.state.pdfUrl = ''
      this.state.apiError = true
      console.error(`Load latest policy failed: ${source.message}`)
    } finally {
      this.state.apiLoading = false
    }
  }

  private initDirectUrl(params: PolicyRouteParams): void {
    const url: string = params.url?.trim() ?? ''
    this.state.pdfUrl = params.downloadUrl?.trim() ?? ''

    if (url.length === 0) {
      this.state.webError = true
    }

    this.state.htmlUrl = url
  }

  onWebLoadStart(): void {
    this.state.webLoading = true
    this.state.webError = false
  }

  onWebLoadingFinish(): void {
    this.state.webLoading = false
  }

  onWebLoadError(): void {
    this.state.webLoading = false
    this.state.webError = true
  }

  preparedRetry(): void {
    this.state.webLoading = true
    this.state.webError = false
  }
}
