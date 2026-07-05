# CLAUDE.md — 个人记账本 (Daily Ledger)

> HarmonyOS NEXT 课程设计项目 — 项目 25
> 选题来源：`E:\资料\2026移动开发课程设计-HarmonyOS选题清单.pdf`

## 项目概况

基于 HarmonyOS NEXT (API 12) 的个人记账应用，帮助用户记录日常收支、分类管理账单、生成月度统计与趋势分析。

| 配置项 | 值 |
|--------|-----|
| **平台** | HarmonyOS NEXT (API 12, 5.0.0) |
| **语言** | ArkTS |
| **模型** | Stage 模型 |
| **IDE** | DevEco Studio |
| **bundleName** | `com.example.dailyledger` |
| **版本** | 1.0.0 |

## 目录结构

```
daily-ledger/
├── build-profile.json5          # 根构建配置
├── hvigorfile.ts                # 根构建脚本
├── oh-package.json5             # 依赖声明
├── AppScope/
│   ├── app.json5                # 应用级配置
│   └── resources/               # 全局资源
└── entry/                       # 主模块
    ├── build-profile.json5
    ├── hvigorfile.ts
    ├── oh-package.json5
    └── src/main/
        ├── module.json5         # 模块清单
        ├── ets/
        │   ├── entryability/    # UIAbility
        │   └── pages/           # 页面
        └── resources/           # 模块资源
```

## 功能需求（来自 PDF）

1. **收支账单 CRUD** — 云数据库存储，支持增删改查
2. **二级分类体系** — 自定义收支分类与图标
3. **月度统计图表** — 分类占比 + 趋势分析
4. **服务卡片** — 桌面展示当月概况 + 快速记账
5. **月度预算** — 预算设定 + 超支推送提醒
6. **全文搜索** — 金额/备注/分类多维度检索
7. **一多适配** — 多设备屏幕适配

## 约束

- 必须使用 DevEco Studio 开发（非 Android Studio）
- 必须使用 HarmonyOS SDK（非 Android SDK）
- 华为云服务：CloudDB、云存储、云函数
- SSH 推送到 `git@github.com:Dew-Fire/daily-ledger.git`（待配置）

## 相关资源

- Android 项目（另一门课）：`E:\LEARNING\Android\CLAUDE.md`
- 全局 CLAUDE.md：`E:\LEARNING\Android\CLAUDE.md`（包含两门课的对比总览）
