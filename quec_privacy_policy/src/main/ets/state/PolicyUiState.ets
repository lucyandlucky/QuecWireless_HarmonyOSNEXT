@ObservedV2
export class PolicyUiState {
  @Trace title: ResourceStr = ''
  @Trace htmlUrl: string = ''
  @Trace pdfUrl: string = ''
  @Trace apiLoading: boolean = false
  @Trace webLoading: boolean = false
  @Trace downloading: boolean = false
  @Trace webError: boolean = false
  @Trace errorMessage: string = ''
}