import { QuecDialogOptions } from './QuecDialogTypes'

export type QuecDialogPlacement = 'center' | 'bottom'

export class QuecDialogResolvedOptions {
  placement: QuecDialogPlacement = 'center'
  width: Length = '80%'
  height: Length | undefined = undefined
  maxWidth: Length | undefined = undefined
  maxHeight: Length = '90%'
  cornerRadius: Length | BorderRadiuses = 16
  backgroundColor: ResourceColor = $r('app.color.B2')
  maskColor: ResourceColor = '#66000000'
  closeOnMask: boolean = true
  closeOnBack: boolean = true
  safeAreaBottom: boolean = false
  keyboardAvoidMode: KeyboardAvoidMode = KeyboardAvoidMode.DEFAULT
  dismissKeyboardOnOpen: boolean = false
  /** Legacy transition applied to the complete dialog, including its mask. */
  transition: TransitionEffect | undefined = undefined
  /** Transition for the dialog content, independent from the mask. */
  dialogTransition: TransitionEffect | undefined = undefined
  /** Transition for the dialog mask, independent from the content. */
  maskTransition: TransitionEffect | undefined = undefined
  onWillDismiss: Callback<DismissDialogAction> | undefined = undefined
  onClosed: (() => void) | undefined = undefined
}

/** Create a private snapshot; never fill defaults into the caller's object. */
export function resolveQuecDialogOptions(
  placement: QuecDialogPlacement,
  options?: QuecDialogOptions
): QuecDialogResolvedOptions {
  const resolved = new QuecDialogResolvedOptions()
  resolved.placement = placement
  resolved.width = options?.width ?? (placement === 'bottom' ? '100%' : '80%')
  resolved.height = options?.height
  resolved.maxWidth = options?.maxWidth
  resolved.maxHeight = options?.maxHeight ?? '90%'
  resolved.cornerRadius = options?.cornerRadius ?? (placement === 'bottom'
    ? { topLeft: 24, topRight: 24, bottomLeft: 0, bottomRight: 0 }
    : 16)
  resolved.backgroundColor = options?.backgroundColor ?? $r('app.color.B2')
  resolved.maskColor = options?.maskColor ?? '#66000000'
  resolved.closeOnMask = options?.closeOnMask ?? true
  resolved.closeOnBack = options?.closeOnBack ?? true
  resolved.safeAreaBottom = options?.safeAreaBottom ?? placement === 'bottom'
  resolved.keyboardAvoidMode = options?.keyboardAvoidMode ?? KeyboardAvoidMode.DEFAULT
  resolved.dismissKeyboardOnOpen = options?.dismissKeyboardOnOpen ?? placement === 'bottom'
  // `transition` is kept for compatibility with callers that intentionally
  // animate the whole dialog. For the default bottom sheet, use the API 19+
  // split transitions so only the content moves while the mask fades in/out.
  const hasLegacyTransition = options?.transition !== undefined
  resolved.transition = options?.transition
  resolved.dialogTransition = hasLegacyTransition ? undefined : options?.dialogTransition ??
    (placement === 'bottom'
      ? TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 300 })
      : undefined)
  resolved.maskTransition = hasLegacyTransition ? undefined : options?.maskTransition ??
    (placement === 'bottom'
      ? TransitionEffect.OPACITY.animation({ duration: 300 })
      : undefined)
  resolved.onWillDismiss = options?.onWillDismiss
  resolved.onClosed = options?.onClosed
  return resolved
}
