allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")

subprojects {
    project.layout.buildDirectory.set(newBuildDir.get().dir(project.name))
}

subprojects {
    plugins.withId("com.android.application") {
        configure<com.android.build.gradle.BaseExtension> {
            externalNativeBuild {
                cmake {
                    version = "3.22.1"
                }
            }
        }
    }
    plugins.withId("com.android.library") {
        configure<com.android.build.gradle.BaseExtension> {
            externalNativeBuild {
                cmake {
                    version = "3.22.1"
                }
            }
        }
    }
}

subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            configure<com.android.build.gradle.BaseExtension> {
                ndkVersion = "29.0.13113456"
                compileSdkVersion(34)
                
                defaultConfig {
                    targetSdkVersion(34)
                }
            }
            
            if (project.plugins.hasPlugin("com.android.library")) {
                val android = project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
                if (android != null && android.namespace == null) {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val xml = manifestFile.readText()
                        val match = Regex("package=\"([^\"]+)\"").find(xml)
                        if (match != null) {
                            android.namespace = match.groupValues[1]
                        }
                    }
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
