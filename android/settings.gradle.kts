pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        mavenLocal()
        // 仅本地启用阿里云镜像加速;CI(GitHub Actions 默认注入 CI=true)直连官方源,
        // 避免镜像 502 时 Gradle 整体 disable 该仓库导致构建失败
        if (System.getenv("CI") == null) {
            maven(url = "https://maven.aliyun.com/repository/public")
            maven(url = "https://maven.aliyun.com/repository/google")
        }

        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.13.2" apply false
    id("org.jetbrains.kotlin.android") version "2.3.0" apply false
}

include(":app")
