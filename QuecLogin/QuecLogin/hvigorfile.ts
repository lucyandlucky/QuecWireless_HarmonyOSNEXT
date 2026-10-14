import { modulePlugin } from '@hadss/hmrouter-plugin';
import { harTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: harTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [modulePlugin()]       /* Custom plugin to extend the functionality of Hvigor. */
}