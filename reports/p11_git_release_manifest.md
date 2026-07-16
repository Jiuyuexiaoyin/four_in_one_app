# P11 Git release manifest

日期：2026-07-16
分支：`p7-ui-foundation`
远端：`origin` → `https://github.com/Jiuyuexiaoyin/four_in_one_app.git`

## P11-GIT-PUBLISH-ONLY 暂存前分类

本节记录恢复 Git 元数据写权限后的显式暂存分类。分类快照来自
`git diff --name-only --diff-filter=ACMRTUXB` 与
`git ls-files --others --exclude-standard`；路径集合共 267 项，SHA-256 为
`EDDE88173C6E192FD2ECD1D58D17520513BA0168552454E9911519314AC74125`。

- 当前分支与远端符合预期；本地分支已配置跟踪 `origin/p7-ui-foundation`。
- `.git/index.lock` 不存在；临时 `.git/p11_write_probe.tmp` 可创建并立即删除，且未修改 refs。
- 暂存区为空；没有已跟踪删除。
- 54 个已跟踪修改 + 213 个未跟踪项目文件，与上次报告的 54 + 211 + 2 个最终报告完全相符。
- 候选总大小 7,657,876 字节；最大候选为 249,907 字节。没有候选超过 10 MB、25 MB 或 100 MB。
- `git diff --check` 通过；只有 Windows 工作区预期的 LF→CRLF 提示。
- P11 发布报告之后较晚的时间戳仅出现在预期的报告/文档/`.gitignore` 整理中；没有应用源码、测试或生产资源晚于已记录验证。

### A. INCLUDE（267 项）

下列范围覆盖分类快照中的每一个已跟踪修改和未跟踪项目文件；范围内没有排除例外：

| 已审查范围 | 项数 | 明确内容 |
| --- | ---: | --- |
| 仓库根文件 | 6 | `.gitignore`、`AGENTS.md`、`README.md`、`CHANGELOG.md`、`pubspec.yaml`、`pubspec.lock` |
| `android/` | 30 | Manifest、Kotlin bridge、Gradle 仓库配置、legacy/adaptive/themed/round launcher、splash、notification 与 values/raw 资源 |
| `assets/branding/` | 19 | Get Ready SVG 母版、生成 PNG 与资产 manifest |
| `docs/` | 13 | 品牌、架构、通知、版本与稳定仓库截图 |
| `ios/Runner/Info.plist` | 1 | iOS 可见产品名 `Get Ready` |
| `lib/` | 45 | 已完成的 P8/P9/P10/P11 Flutter 应用、同步、权限、通知与 UI 工作 |
| `reports/` | 130 | P8–P11 审计、设计、QA、权限、品牌、运行时与发布证据，以及 proof PNG/占位 `.gitkeep` |
| `test/` | 20 | 已验证的既有与新增自动化测试 |
| `tools/branding/` | 3 | 可复现品牌生成器、PowerShell 入口和说明 |

`reports/apk_golden_*.md` 等早期报告按其文档日期保留为历史快照；它们不使
`.ai_reference/` 成为提交候选。`android/gradle.properties` 的两个 Flutter
migrator 标志属于已验证的仓库构建配置，不是本机 `local.properties`。

### B. EXCLUDE（忽略的本地/生成内容）

- `.ai_reference/`：44 个原始参考文件，共 160,182,682 字节；包括明确排除的
  `.ai_reference/apk/golden_latest.apk`（154,516,701 字节）。
- `.dart_tool/`：1,599 个生成/缓存文件；`build/`：1,544 个生成文件；
  `.playwright-mcp/`：87 个本地浏览器诊断文件；`android/.gradle/`：18 个缓存文件。
- `android/.kotlin/`、`android/app/src/main/java/` 生成内容、忽略的 Gradle wrapper
  二进制/脚本、`.flutter-plugins-dependencies` 与 iOS Flutter/插件生成文件。
- `android/local.properties`（125 字节）及任何本机 SDK、Flutter SDK、IDE、浏览器 profile 或缓存。
- `build/app/outputs/apk/debug/app-debug.apk` 与
  `build/app/outputs/flutter-apk/app-debug.apk`（各 154,612,423 字节）。
- 任意 APK/AAB、`.env`、认证 JSON、token、密钥、keystore、签名配置、Git/Codex 凭据；当前没有 AAB、候选密钥或候选认证文件。

以上内容均不在 267 项 Git 可见候选中，并由 `.gitignore` 或现有平台 ignore 规则排除。

### C. MANUAL REVIEW

无。路径、扩展名、大小和内容关键词复核已消除所有歧义：

- `lib/app/theme/app_theme_tokens.dart` 的 `tokens` 是设计系统术语。
- 文档中少量 `token`/`secret` 字样均为安全政策或历史说明；高置信秘密格式扫描无命中。
- 两个 `.gitkeep` 是报告证明目录的有意占位文件。
- 早期 APK/Stitch/运行时报告是有日期的历史证据，不是原始参考资产或本机配置。

暂存决定：仅按上述已审查的 267 个显式路径分两批暂存，先处理已跟踪修改，再处理批准的未跟踪文件；不得使用 `git add .` 或 `git add -A`。

## 上次运行结果（历史）

应用、品牌、文档与验证工作已经完成，但本次运行环境只允许读取 `.git`。主代理按显式目录清单执行暂存时，Git 无法创建 `.git/index.lock`：

```text
fatal: Unable to create 'D:/ai/projects/four_in_one_app/.git/index.lock': Permission denied
```

- 已提交文件：无。
- 已暂存文件：无；`git diff --cached --name-only` 为 0 项。
- 新提交：未创建。
- 推送：未执行，避免绕过本地索引或直接改写远端。
- 残留锁文件：无；`.git/index.lock` 不存在。

## 预期提交范围

阻塞前的安全审查记录为 54 个已跟踪修改、211 个未跟踪项目文件；加入本清单与最终报告后新增 2 个报告文件。预期发布提交仅覆盖以下项目路径：

- 根文件：`.gitignore`、`AGENTS.md`、`README.md`、`CHANGELOG.md`、`pubspec.yaml`、`pubspec.lock`。
- 应用源码：`lib/`。
- 自动化测试：`test/`。
- Android 源码、Manifest 与资源：`android/`。
- iOS 可见产品名元数据：`ios/Runner/Info.plist`。
- Get Ready 矢量与生成资产：`assets/branding/`。
- 可复现品牌生成工具：`tools/branding/`。
- 仓库文档和稳定截图：`docs/`。
- P8/P9/P10/P11 的应用 QA、品牌、权限与证明报告：`reports/`。

这些路径包含本次要求一并整合的既有 P8/P9/P10 UI、交互、数据同步、Android 权限/通知工作，以及 P11 Get Ready 2.6.0 品牌与文档工作。未检测到已跟踪文件删除。

## 明确排除

- `.ai_reference/`，包括原始批准参考板。
- `build/` 及 `build/app/outputs/flutter-apk/app-debug.apk`。
- `.dart_tool/`、Gradle/Flutter/Android SDK 缓存与本地 SDK 配置。
- `.playwright-mcp/` 与本地浏览器配置目录。
- `.env`、认证文件、令牌、密钥库、签名配置和 `android/local.properties`。
- Android SDK、Flutter SDK、debug APK、release APK、AAB、GitHub Release 与 tag。

`git check-ignore -v` 已确认参考板、debug APK、`.dart_tool`、Playwright 本地目录、`.env` 和 `android/local.properties` 均被忽略。

## 验证结果

- 定向 Dart 格式化：通过，仅处理本阶段修改的 4 个 Dart 文件。
- `flutter analyze`：通过，`No issues found!`。
- `flutter test`：251/251 通过。
- `flutter build apk --debug`：通过。
- `git diff --check`：通过；仅有预期的 LF/CRLF 提示。
- 候选文件高置信秘密扫描：通过；最初命中的 `goals_flow_test.dart` 为 `task-...` 测试键名被 `sk-` 子串规则误判，加入词边界后无命中。
- APK：154,612,423 字节（147.45 MiB）。
- APK SHA-256：`E7DD305C42E9BF6329EEF434D19771A424881F5E36DB6F8F2D4524FB14A92F6A`。
- APK 身份：`com.example.four_in_one_app`，`2.6.0`，versionCode `18`。
- APK 签名：Android debug 证书，APK Signature Scheme v2 验证通过。
- APK 对齐：`zipalign -c -P 16 4` 通过。

## 分支与远端状态

- 当前本地 HEAD：`394b5ebbe284235828b9df41a0ddd87341955cc3`（P11 前的既有提交）。
- 缓存的 `origin/p7-ui-foundation`：`394b5ebbe284235828b9df41a0ddd87341955cc3`。
- 实时 `git ls-remote` 未返回远端头并以退出码 1 结束，因此未声明实时远端一致性。
- GitHub CLI 已安装，但 `gh auth status` 报告当前凭据无效；仓库 description/topics 未更新。

建议手动设置的仓库描述：

```text
Get Ready — a local-first Flutter productivity app for habits, planning, focus, review, and Android reminders.
```

建议 topics：`flutter`、`dart`、`android`、`productivity`、`habit-tracker`、`focus-timer`、`local-first`、`notifications`。

## 安全续接动作

在允许当前工作区写入 `.git` 的 Codex/终端会话中，从 Phase 13 继续：先重新审查状态，再按上述明确路径暂存，执行 cached diff/秘密/大文件检查，创建 `release: prepare Get Ready 2.6.0` 提交，并以普通非强制推送更新 `origin/p7-ui-foundation`。不要把令牌发到聊天中，也不要使用替代 Git 目录、force-push、tag、Release 或 PR 来绕过本阻塞。
