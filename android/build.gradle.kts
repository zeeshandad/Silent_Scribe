allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    plugins.withId("com.android.application") {
        configure<com.android.build.gradle.BaseExtension> {
            ndkVersion = "29.0.13113456"
            externalNativeBuild {
                cmake {
                    version = "3.22.1"
                }
            }
        }
    }
    plugins.withId("com.android.library") {
        configure<com.android.build.gradle.BaseExtension> {
            ndkVersion = "29.0.13113456"
            externalNativeBuild {
                cmake {
                    version = "3.22.1"
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
