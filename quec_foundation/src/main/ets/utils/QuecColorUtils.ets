import { ColorMetrics } from '@kit.ArkUI'

export class QuecColorUtils {
  static getColorWithAlpha(alpha: number, baseColor: ResourceColor): string {
    try {
      const colorMetrics = ColorMetrics.resourceColor(baseColor)
      const androidAlpha = Math.min(255, Math.max(0, Math.floor(alpha * 255))) / 255
      return ColorMetrics.rgba(
        colorMetrics.red,
        colorMetrics.green,
        colorMetrics.blue,
        androidAlpha
      ).color
    } catch (_) {
      return '#00000000'
    }
  }
}
