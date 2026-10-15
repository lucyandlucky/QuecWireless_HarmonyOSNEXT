import { MainTabModel } from '../model/MainTabModel';

@ObservedV2
export class MainUiState {
  @Trace tabs: MainTabModel[] = []
  @Trace selectedIndex: number = 0
}
