import { QuecOemTab } from '@quec/oem-app-config';

@ObservedV2
export class MainUiState {
  @Trace tabs: QuecOemTab[] = []
  @Trace selectedIndex: number = 0
}
