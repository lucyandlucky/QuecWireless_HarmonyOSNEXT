import { ComponentBuilderContext } from '@rnoh/react-native-openharmony'

@Builder
export function buildQuecRNComponent(ctx: ComponentBuilderContext) {
  if (ctx.customRNComponentWrappedBuilderByName.has(ctx.componentName)) {
    ctx.customRNComponentWrappedBuilderByName.get(ctx.componentName)!.builder(ctx)
  }
}
