import { QuecDialogContent } from '@quec/basic-ui'

export interface QuecRNErrorDialogData {
  onBack: () => void
}

@Builder
export function buildQuecRNErrorDialog(content: QuecDialogContent<QuecRNErrorDialogData>) {
  Column({ space: 24 }) {
    Text('面板加载失败')
      .fontSize(17)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.W1'))
      .textAlign(TextAlign.Center)
      .width('100%')
    Button('返回')
      .width('100%')
      .height(44)
      .fontSize(16)
      .fontColor(Color.White)
      .backgroundColor($r('app.color.M0'))
      .onClick(() => content.data.onBack())
  }
  .width('100%')
  .padding(24)
}
