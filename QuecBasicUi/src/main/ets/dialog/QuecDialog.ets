import { UIContext } from '@kit.ArkUI'
import { resolveQuecDialogOptions } from './QuecDialogConfig'
import { QuecDialogCore } from './QuecDialogCore'
import { QuecDialogContent, QuecDialogHandle, QuecDialogOptions } from './QuecDialogTypes'

/** No global UIContext, root placeholder or required initialization. */
export class QuecDialog {
  static showCenter<T extends Object>(
    uiContext: UIContext,
    builder: WrappedBuilder<[QuecDialogContent<T>]>,
    data: T,
    options?: QuecDialogOptions
  ): QuecDialogHandle<T> {
    return new QuecDialogCore(uiContext, builder, data, resolveQuecDialogOptions('center', options))
  }

  static showBottom<T extends Object>(
    uiContext: UIContext,
    builder: WrappedBuilder<[QuecDialogContent<T>]>,
    data: T,
    options?: QuecDialogOptions
  ): QuecDialogHandle<T> {
    return new QuecDialogCore(uiContext, builder, data, resolveQuecDialogOptions('bottom', options))
  }
}
