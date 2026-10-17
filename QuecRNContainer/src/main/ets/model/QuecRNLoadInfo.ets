export enum QuecRNBundleSource {
  Resource,
  File,
  Metro
}

export interface QuecRNLoadInfo {
  bundleId: string
  appKey: string
  bundlePath: string
  bundleSource?: QuecRNBundleSource
  assetsDest?: string
  initialProps?: Record<string, string>
}
