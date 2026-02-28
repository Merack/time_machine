# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目简介

TimeMachine 是一个基于 Flutter 的专注计时器（番茄钟变体）应用，仅支持 Android 平台。

## 常用命令

```bash
flutter pub get              # 安装依赖
flutter run                  # 调试运行
flutter build apk --release  # 构建 release APK
flutter test                 # 运行所有测试
flutter analyze              # 静态分析
flutter test test/xxx_test.dart  # 运行单个测试文件
```

Android 层：
```bash
cd android && ./gradlew assembleDebug
cd android && ./gradlew assembleRelease
```

Release 签名通过 `android/key.properties` 配置（不在版本控制中）。

## 架构概览

采用 **GetX** 框架，MVC 三层分离：Controller + State + View。

### 目录结构

```
lib/
├── main.dart              # 入口，异步初始化所有服务
├── config/                # 常量（StorageKeys, AppConfig）
├── dao/                   # 数据访问层（FocusSessionDao, SettingDao）
├── database/              # DatabaseHelper, 统计服务, 备份恢复
├── model/                 # 数据模型
├── page/                  # 页面，每页包含 controller/state/view/widgets
├── route/                 # GetX 命名路由
├── service/               # 核心服务
└── theme/                 # ThemeController + AppThemes
```

### 核心服务层

- `AppStorageService`：基于 MMKV 的 KV 存储，用于用户设置持久化
- `DatabaseService`：SQLite 数据库服务（`time_machine.db`，表 `focus_sessions`）
- `BackgroundTimerService`：管理后台 isolate 的生命周期
- `TimerBgServiceHandler`：后台 isolate 中运行的计时逻辑

### 双 Isolate 架构

主 isolate（UI）与后台 isolate（计时器）通过 `FlutterBackgroundService` 的事件通道双向通信：
```dart
_backgroundService.on("event_name").listen(...)  // 监听事件
_backgroundService.invoke("event_name", data)    // 发送事件
```

### 依赖注入

使用 GetX：
```dart
Get.putAsync<ServiceType>(() async => ...)  // 异步注册服务
Get.find<ServiceType>()                     // 获取服务实例
```

## 关键技术栈

| 库 | 用途 |
|---|---|
| `get ^4.7.2` | 状态管理、路由、依赖注入 |
| `mmkv ^2.2.2` | 高性能 KV 存储 |
| `sqflite ^2.4.2` | SQLite 数据库 |
| `flutter_background_service ^5.1.0` | 后台 isolate 保活 |
| `flutter_local_notifications ^19.3.0` | 前台服务通知 |
| `audioplayers ^6.5.0` | 提示音播放 |

## Android 配置

- `minSdk = 23`，Kotlin `2.1.0`，AGP `8.7.3`
- 启用 `coreLibraryDesugaring`（`desugar_jdk_libs:2.1.4`）
- Maven 依赖走阿里云镜像（`maven.aliyun.com`）
