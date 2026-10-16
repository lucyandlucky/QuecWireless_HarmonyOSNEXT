# QuecDialog

`QuecDialog` provides center and bottom dialog shells. There is no required initialization or root placeholder. Supply the current page's `UIContext` on each call; content, spacing, scrolling and business actions belong to the page.

```typescript
import { QuecDialog, QuecDialogContent, QuecDialogHandle } from '@quec/basic-ui'

class DialogData {
  message: string = ''
}

@Builder
function buildContent(content: QuecDialogContent<DialogData>) {
  Column({ space: 24 }) {
    Text(content.data.message)
    Button('关闭')
      .onClick(async () => {
        await content.close()
      })
  }
  .width('100%')
  .padding(24)
}

// Inside a page method:
const handle: QuecDialogHandle<DialogData> = QuecDialog.showCenter(
  this.getUIContext(),
  wrapBuilder(buildContent),
  { message: '内容由页面编写' },
  { width: 311, cornerRadius: 16, closeOnMask: false }
)
handle.ready.catch((error: Error) => {
  console.error(error.message)
})
```

Use `showBottom` with the same arguments for bottom placement. Defaults are a themed `B2` background, `#66000000` mask and a maximum height of `90%`. Center defaults to width `80%` and radius `16`; bottom defaults to width `100%`, top radii `24`, a bottom-edge content transition and an opacity mask transition. Every size and transition can be overridden. Use `dialogTransition` and `maskTransition` for independent motion; the legacy `transition` option still applies to the complete dialog. Height follows content unless specified. The host does not insert a title, buttons, content padding or a Scroll.

Bottom dialogs include the owning window's navigation inset and listen for inset changes. While the IME is visible, that navigation inset is suppressed because `keyboardAvoidMode` already positions the sheet around the keyboard. Bottom dialogs also clear the current page focus before opening by default; set `dismissKeyboardOnOpen: false` when a dialog intentionally keeps the IME open. Do not add the same inset inside the content. Set `safeAreaBottom: false` when the content intentionally manages it itself.

If `transition` and either split transition are supplied together, the legacy `transition` takes precedence and is applied to the complete dialog. Use `dialogTransition` and `maskTransition` without `transition` when their motions should remain independent.

`showCenter` / `showBottom` immediately return an independent handle:

- `ready`: the system open request completed; appearance animation may still be running. If closed before creation starts, no native dialog is opened.
- `close()`: waits for an in-flight open and then closes. Repeated calls share the pending operation. An unsuccessful close retains native content and can be retried.
- `closed`: content has been released, including opening failure. `onClosed` has the same once-only cleanup semantics.
- `update(data)`: replaces only the content Builder's data. It does not change shell options. Updates after closing begins are ignored. Use `@Param` in content components to receive replacement data, or their own `@Local` state for internal interactions.

Store the handle on the owning page, close it from both router `onHidden` and component destruction, and clear the stored reference from `onClosed`. This is necessary for router-cached pages. Handle `ready` and `close()` rejections where page-specific error feedback is needed.

By default, mask and back interactions follow `closeOnMask` and `closeOnBack`. If supplied, `onWillDismiss` handles dismissal callbacks emitted by the system and calls its `action.dismiss()` to use the same close/cleanup path. `closeOnMask: false` also sets native `autoCancel: false`; it does not guarantee a mask-touch callback will be emitted. Calling `handle.close()` is an explicit close and does not invoke this interactive policy. Opening failure releases the newly created content. Closing success or SDK error `103303` (native content not found) releases it; other close failures preserve it for retry. `onDidDisappear` is an additional cleanup path, not the only one.
