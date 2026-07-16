# P11 Get Ready 2.6.0 release report

日期：2026-07-16

## 1. 最终产品名

`Get Ready`。所有新增用户可见命名使用强制大小写与空格，批准标语为“随时准备，迎接每一次机会。”。内部稳定资源名、通知 channel ID 与 Dart/Android 标识符按约束保留技术命名。

## 2. 最终版本

- versionName：`2.6.0`
- versionCode：`18`
- Flutter：`version: 2.6.0+18`

当前已知 build number 为 17，因此按要求递增到 18，无需采用“当前值加一”的异常分支。

## 3. 包身份

Android namespace 与 application ID 均保持 `com.example.four_in_one_app`，未修改 GitHub 仓库名、路由、持久化 schema 或安装包身份。

## 4. 新标志几何

1000 × 1000 母版画布；圆弧中心 `(430, 500)`、半径 `220`、描边 `80`、向右打开 `110°`，端点圆角半径 `40`；状态条为 `230 × 80`、圆角半径 `40`；就绪圆点直径 `88`。主色为 Ink black `#111111` 与 Brand green `#16A34A`。完整安全区、最小尺寸和禁止变形规则见 `reports/p11_get_ready_geometry_spec.md`。

## 5. 旧品牌替换

生产用旧三阶梯 SVG、生成 PNG、旧 manifest、launcher、通知与 splash 视觉已由 open-arc/status-bar/dot 标志取代。P10 报告和对比图仅作为历史证据保留，不被生产代码引用；`old_vs_new_brand_comparison.png` 仅用于证明，不是生产资产。

## 6. Launcher / adaptive / themed 图标

已生成 5 个标准密度与 round launcher PNG；adaptive icon 使用 `#111111` 独立背景层和无预制圆角的透明前景；Android 13+ v33 资源引用有效 monochrome 图层。APK 资源表确认 legacy、round、v26 与 v33 资源均已打包。

## 7. 通知图标

`ic_stat_getready` 为透明背景、无容器、无颜色/渐变/阴影的单色小图标；`raw/keep.xml` 保留该资源，同时保留 P9 兼容资源 `ic_stat_checkin`。通知 channel ID、调度、receiver 与 deep-link 行为未更名或削弱。

## 8. Splash

legacy Android splash 使用 `#111111` 背景与新纵向锁定标志；Android 12+ 使用居中的 mark-only vector，避免超出系统约束。Flutter 首帧使用精确 `Get Ready` wordmark 与批准标语，不加入人工延迟。

## 9. About、Web 与平台命名

Settings/About 已更新为新 mark、`Get Ready`、`2.6.0` 与标语，并保持局部紧凑布局。Android application label 与 iOS display name 为 `Get Ready`。仓库当前没有 `web/` 或 `windows/` 平台目录，因此没有伪造对应 metadata，也未让缺失平台阻塞 Android 交付。

## 10. README 与文档

已重写简体中文 `README.md`，覆盖产品、真实功能、截图、设计系统、技术栈、架构、隐私、权限、运行/测试、构建输出、质量、限制、路线图与许可证状态；新增/更新 `CHANGELOG.md`、`docs/BRAND.md`、`docs/ARCHITECTURE.md`、`docs/ANDROID_NOTIFICATIONS.md` 与 `docs/screenshots/README.md`，并复制稳定仓库相对路径截图。

## 11. GitHub metadata

`gh` 已安装，但 `gh auth status` 报告 Jiuyuexiaoyin 当前凭据无效，因此没有修改 description、topics、visibility、仓库名、Release 或 tag。建议 description 与 topics 已写入 `reports/p11_git_release_manifest.md`，该问题不影响已完成的本地应用验证。

## 12. 文件变更

Git 阻塞前记录为 54 个已跟踪修改和 211 个未跟踪项目文件；本清单和本报告再新增 2 个报告。变更集中在 Flutter 源码/测试、Android/iOS 元数据与资源、品牌母版与生成脚本、README/docs、截图和 P8–P11 QA 报告。没有已跟踪文件删除。

## 13. Analyze

`D:\ai\flutter\bin\flutter.bat analyze`：通过，`No issues found!`。

## 14. 完整测试

`D:\ai\flutter\bin\flutter.bat test`：251/251 通过。

## 15. Debug APK

`D:\ai\flutter\bin\flutter.bat build apk --debug`：通过。未构建 release APK，未准备 AAB，未把 APK 加入 Git。

## 16. APK 路径、大小与 SHA-256

- 路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 大小：154,612,423 字节（147.45 MiB）
- SHA-256：`E7DD305C42E9BF6329EEF434D19771A424881F5E36DB6F8F2D4524FB14A92F6A`
- min SDK：24
- target SDK：36
- compile SDK：36
- debug 签名：Android Debug，v2 验证通过
- 16 KB 对齐：`zipalign -c -P 16 4` 通过

## 17. 最终权限

APK 最终清单包含：

- `android.permission.POST_NOTIFICATIONS`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.VIBRATE`
- debug/profile 构建所需 `android.permission.INTERNET`
- AndroidX 自动生成的包内 `com.example.four_in_one_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

没有新增 camera、microphone 或 broad storage 权限，P9 已接受权限集合保持不变。

## 18. Commit hash

未创建 P11 提交。当前既有本地 HEAD 仍为 `394b5ebbe284235828b9df41a0ddd87341955cc3`。原因是运行环境拒绝 Git 创建 `.git/index.lock`，不是测试、构建或 staged review 失败。

## 19. 推送分支

目标分支仍为 `p7-ui-foundation`；本次未执行 push，未 merge main、未 force-push、未创建 PR/tag/Release。

## 20. 远端验证

本地缓存的 `origin/p7-ui-foundation` 与既有本地 HEAD 同为 `394b5ebbe284235828b9df41a0ddd87341955cc3`。实时 `git ls-remote` 以退出码 1 结束且未返回远端头，因此没有声称完成 P11 远端验证。

## 21. 排除的本地与构建文件

`.ai_reference/`、debug APK、`build/`、`.dart_tool/`、Gradle/Flutter/Android SDK 缓存、Playwright/浏览器配置、`android/local.properties`、`.env`、认证/令牌/密钥/签名文件均保持排除。没有删除 build、`.dart_tool`、Pub 或 Gradle cache。

## 22. 实体设备复核项

`flutter devices` 仅发现 Windows、Chrome 与 Edge，没有 Android 实机。仍需在实体 Android 设备/OEM launcher 上复核 adaptive mask、Android 13 themed icon、Android 12 splash、状态栏通知小图标、通知权限提示、重启恢复与厂商后台限制。

## 阻塞与安全续接

应用与 APK 已完成验证，但当前沙箱对 `.git` 为只读，显式 `git add` 报 `Permission denied`；索引未变化，`.git/index.lock` 不存在。唯一安全续接方式是在具备本仓库 `.git` 写权限的会话中重新执行 Phase 13–14 的暂存审查、单一 release commit 与普通 push。不得通过替代 Git 目录、直接远端提交、force-push 或聊天传递令牌绕过。

BLOCKED_BY_RUNTIME
