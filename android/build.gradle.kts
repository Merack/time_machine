allprojects {
    repositories {
        mavenLocal()
        // 仅本地启用阿里云镜像加速;CI 直连官方源,避免镜像 502 拖垮构建
        if (System.getenv("CI") == null) {
            maven(url = "https://maven.aliyun.com/repository/public")
            maven(url = "https://maven.aliyun.com/repository/google")
        }

        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
