buildscript {
    repositories {
        google()        // ✅ required
        mavenCentral()  // ✅ required
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.4.2") // keep whatever you already use
        classpath("com.google.gms:google-services:4.3.15") // ✅ your line
    }
}

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
