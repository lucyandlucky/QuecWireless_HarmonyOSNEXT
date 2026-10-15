# QuecDeviceSdk

设备 SDK HAR，包名为 `@quec/device-sdk`，通过 `QuecDeviceService.getDeviceList()` 提供普通设备列表查询。

```typescript
import { QuecDeviceListParamsModel, QuecDeviceService } from '@quec/device-sdk'

const params = new QuecDeviceListParamsModel()
params.page = 1
params.pageSize = 10
const response = await QuecDeviceService.getDeviceList(params)
const devices = response.data.list
const hasMore = response.data.hasNextPage
```

使用前由宿主初始化 `QuecNetworkV2` 并加载 OEM 网络配置；SDK 复用该客户端的请求头、Token 与业务错误处理，无需单独初始化。

查询使用 PaaS 地址下的 `GET /v2/binding/enduserapi/userDeviceList`。调用方填写分页与筛选条件，API 直接传递参数；数字与布尔值由网络层序列化。可选条件为空时不赋值，或赋为 `undefined`；网络层会省略 `undefined`、`null`，但保留空字符串。成功后返回完整的 PaaS 列表响应，设备列表位于 `response.data.list`；请求失败由网络层抛出错误，由调用方处理。

网络层通过 `QuecPaaSResponse<T>` 描述普通 PaaS 成功响应，字段为 `code`、`msg`、`data: T`、`extMsg`。`QuecPaaSListResponse<T>` 继承 `QuecPaaSResponse<QuecPaaSPageData<T>>`，描述完整的 PaaS 列表成功响应，其分页数据包含列表、总数、页码、页大小、前后页、翻页状态与导航页码等全部字段。

`QuecNetworkV2` 的 `get/post/put/delete` 泛型统一表示完整响应，返回 `Promise<T>`。普通接口使用 `get<QuecPaaSResponse<UserModel>>()`，列表接口使用 `get<QuecPaaSListResponse<DeviceModel>>()`。业务错误由网络拦截器抛出。

当前 SDK 保留服务端返回的完整分页字段，不额外创建应用层分页对象。以后接入 SaaS 等不同分页结构时，再按具体协议增加适配器。

设备字段先覆盖普通列表所需的数据。能力位为零或缺失时归一为 `1`，分享设备标记按 `shareCode` 计算。列表缓存、页面状态和卡片交互由业务模块管理。

