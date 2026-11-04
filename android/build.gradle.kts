allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Windows / OneDrive safeguard: automatically clears read-only and cloud offline
// attributes on build artifacts via cmd attrib -r -o -u +p before tasks run.
subprojects {
    tasks.configureEach {
        if (name.contains("merge", ignoreCase = true) || name.contains("clean", ignoreCase = true) || name.contains("native", ignoreCase = true) || name.contains("assemble", ignoreCase = true)) {
            doFirst {
                try {
                    val buildDirFile = project.layout.buildDirectory.orNull?.asFile
                    if (buildDirFile != null && buildDirFile.exists()) {
                        if (System.getProperty("os.name").lowercase().contains("windows")) {
                            ProcessBuilder("cmd.exe", "/c", "attrib", "-r", "-o", "-u", "+p", "\"${buildDirFile.absolutePath}\"", "/s", "/d")
                                .redirectErrorStream(true)
                                .start()
                                .waitFor()
                            ProcessBuilder("cmd.exe", "/c", "attrib", "-r", "-o", "-u", "+p", "\"${buildDirFile.absolutePath}\\*\"", "/s", "/d")
                                .redirectErrorStream(true)
                                .start()
                                .waitFor()
                        }
                    }
                } catch (_: Exception) {}
            }
        }
    }
}

tasks.register<Delete>("clean") {
    doFirst {
        try {
            val rootBuild = rootProject.layout.buildDirectory.orNull?.asFile
            if (rootBuild != null && rootBuild.exists()) {
                if (System.getProperty("os.name").lowercase().contains("windows")) {
                    ProcessBuilder("cmd.exe", "/c", "attrib", "-r", "\"${rootBuild.absolutePath}\"", "/s", "/d")
                        .redirectErrorStream(true)
                        .start()
                        .waitFor()
                    ProcessBuilder("cmd.exe", "/c", "attrib", "-r", "\"${rootBuild.absolutePath}\\*\"", "/s", "/d")
                        .redirectErrorStream(true)
                        .start()
                        .waitFor()
                }
            }
        } catch (_: Exception) {}
    }
    delete(rootProject.layout.buildDirectory)
}
