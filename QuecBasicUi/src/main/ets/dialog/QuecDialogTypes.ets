/** Parameters supplied to a page-owned dialog Builder. */
export interface QuecDialogContent<T extends Object> {
  data: T
  close: () => Promise<void>
}

/** One dialog instance. It is available before the asynchronous open completes. */
export interface QuecDialogHandle<T extends Object> {
  /** Resolves when the system accepts the open request, before animation completion. */
  readonly ready: Promise<void>
  /** Resolves once the content has been released, including an unsuccessful open. */
  readonly closed: Promise<void>
  close(): Promise<void>
  /** Replaces Builder data; shell options remain unchanged. */
  update(data: T): void
}

export interface QuecDialogOptions {
  width?: Length
  height?: Length
  maxWidth?: Length
  maxHeight?: Length
  cornerRadius?: Length | BorderRadiuses
  backgroundColor?: ResourceColor
  maskColor?: ResourceColor
  closeOnMask?: boolean
  closeOnBack?: boolean
  /** Bottom dialogs include the current window's navigation inset by default. */
  safeAreaBottom?: boolean
  keyboardAvoidMode?: KeyboardAvoidMode
  /** Clear the current page focus before opening; bottom dialogs default to true. */
  dismissKeyboardOnOpen?: boolean
  /**
   * Legacy transition applied to the complete dialog, including its mask.
   * Prefer dialogTransition and maskTransition when they need independent motion.
   */
  transition?: TransitionEffect
  /** Transition effect for the dialog content only (API 19+). */
  dialogTransition?: TransitionEffect
  /** Transition effect for the modal mask only (API 19+). */
  maskTransition?: TransitionEffect
  /** Handles system dismissal callbacks instead of the default policy. Call action.dismiss() to close. */
  onWillDismiss?: Callback<DismissDialogAction>
  /** Called once after cleanup, also when opening fails. */
  onClosed?: () => void
}
