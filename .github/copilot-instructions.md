## Copilot / AI Agent 使用说明 — NAI-Generator-Flutter

本文件为 AI 编码代理提供简洁、可执行的操作指南，帮助迅速在本仓库中开展工作。

总体概览
- 目的：NAI CasRand 是一个通过随机级联 prompt 生成图像并调用图像生成 API 的 Flutter 应用。
- 代码划分：界面位于 `lib/ui`；数据模型与服务位于 `lib/data`；通用工具/常量在 `lib/core`。
- 依赖注入：使用 `GetIt`，在 `lib/main.dart` 中以 `GetIt.instance.registerLazySingleton(...)` 注册单例。

关键文件与典型模式（带示例）
- `lib/main.dart`：应用启动与单例注册位置。示例：`GetIt.instance.registerLazySingleton<ConfigService>(() => ConfigService());`
- `lib/data/services/api_service.dart`：网络调用示例。注意：有 `createHttpClient(proxy)`，在非 Web 平台可使用 `IOClient` 并支持代理与不安全证书（仅测试用）；当 `kIsWeb` 或 `proxy==''` 时返回 `null`，使用普通 `http` 客户端。
- `lib/data/services/config_service.dart`：持久化配置加载/保存模式；`PayloadConfig.fromJson(...)` 在启动时用于恢复配置，请遵循其 JSON 结构。
- `pubspec.yaml`：列出依赖与静态资源（见 `flutter.assets`，例如 `assets/l10n/*`、`assets/json/example.json`）。

项目约定（必须遵守的实践）
- 单例与 DI：共享服务和 viewmodel 使用 `GetIt`，务必在 `main()` 初始化并在 `runApp()` 前注册完毕。
- 本地化：使用 `easy_localization`，本地化文件位于 `assets/l10n`，并在 `main.dart` 的 `EasyLocalization` 中声明支持的 `Locale`。
- 网络调用：遵循 `ApiService.fetchData(ApiRequest)` 的返回形态（`ApiResponse { status, data (bytes) }`），新服务若需要代理或桌面支持，应复用 `createHttpClient(proxy)` 的处理逻辑并尊重 `kIsWeb`。
- 配置文件：导出/导入为 JSON（见 `assets/json/example.json`），更改格式时需在 `PayloadConfig.fromJson` 中保证向后兼容。

常用命令（Windows PowerShell）
```powershell
flutter pub get
flutter run
flutter run -d windows
flutter build apk
flutter build ios
flutter test
```

修改代码时的具体建议
- 新增 model：放在 `lib/data/models`。
- 新增 service：放在 `lib/data/services`，如果需全局可访问，记得在 `main.dart` 用 `GetIt.instance.registerLazySingleton(...)` 注册，并在消费处使用 `GetIt.I<MyService>()`。
- 增加本地化或静态资源：把文件放入 `assets/l10n` 或 `assets/...`，并在 `pubspec.yaml` 的 `flutter.assets` 中注册，同时在 `main.dart` 的 `EasyLocalization` 中加入支持的 `Locale`。
- 网络请求契约：若引入新网络服务，建议保持 `fetchData` 签名与 `ApiResponse` 返回结构一致，方便现有代码复用。

示例任务快速指南
- 添加 HTTP 服务：
  - 新建 `lib/data/services/my_service.dart`，按 `ApiService` 的模式实现 `fetchData`（或更高层方法）。
  - 在 `main.dart` 注册为单例：`GetIt.instance.registerLazySingleton(() => MyService());`
  - 在 viewmodel 中获取：`final svc = GetIt.I<MyService>();`
- 添加语言：
  - 新增文件 `assets/l10n/xx.json`（JSON 格式）。
  - 在 `pubspec.yaml` 增加对应 `assets` 条目。
  - 在 `main.dart` 的 `EasyLocalization` supportedLocales 中加入 `Locale('xx')`。

安全与仓库注意事项
- API Token：Token 由用户在设置界面填写，切勿将敏感 token 硬编码进仓库或提交。
- 私有包：`pubspec.yaml` 中保留 `publish_to: 'none'`。

需要我扩展哪些内容？
- 我可以补充 `PayloadConfig` 的 JSON 字段示例、`ConfigService` 常用方法签名、或展示一个完整的新增 service + 注册的代码片段。请告诉我你想要的深度。

