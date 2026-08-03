export const PRIVACY_WEBVIEW_ROUTE = 'QuecPrivacyWebViewPage'

export enum PolicySource {
  LATEST,
  DIRECT_URL
}

export enum PolicyType {
  PRIVACY = 'PRIVACY',
  SERVICE = 'SERVICE'
}

export interface PolicyRouteParams {
  source: PolicySource,
  type?: PolicyType
  url?: string
  title: ResourceStr
  downloadUrl?: string
}