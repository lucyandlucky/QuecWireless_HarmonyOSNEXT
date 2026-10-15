个人中心通用模式：[Figma 节点 44018:35918](https://www.figma.com/design/D6WCPbpzMfxRGovPJaqoMf?node-id=44018-35918)。

顶部背景使用 `src/main/resources/base/media/quec_personal_center_top_bg.png`，按设计尺寸的 3 倍（1125 × 564）导出并保留透明通道。

运行时图片统一使用 PNG，浅色资源放在 `src/main/resources/base/media/`，深色资源放在 `src/main/resources/dark/media/`。两套资源使用相同文件名，页面通过 `$r('app.media.资源名')` 引用，由系统按主题切换。

菜单图标和箭头按设计尺寸的 3 倍导出，并保留透明通道。深色菜单图标使用 `quec_ui_config` 的深色 `W1`（白色），箭头使用两种主题共有的 `W4`。默认头像、顶部背景沿用各自的深色素材。

更新图片时同步替换 `base/media/` 与 `dark/media/` 中的同名 PNG，无需添加着色滤镜或主题判断。

个人信息页参照 [Figma 节点 44018:38796](https://www.figma.com/design/D6WCPbpzMfxRGovPJaqoMf?node-id=44018-38796)，设置页参照 [Figma 节点 44018:36402](https://www.figma.com/design/D6WCPbpzMfxRGovPJaqoMf?node-id=44018-36402)。新增头像编辑标记、资料箭头、设置箭头、深色模式箭头和关闭状态开关，同样使用浅色、深色两套 PNG。开关和升级数量、缓存大小当前仅作设计占位。
