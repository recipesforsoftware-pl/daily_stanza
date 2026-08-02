import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.isFile

if (hasReleaseSigning) {
    FileInputStream(keystorePropertiesFile).use { input ->
        keystoreProperties.load(input)
    }
}

fun signingProperty(name: String): String {
    return keystoreProperties.getProperty(name)
        ?: throw GradleException(
            "Missing '$name' in android/key.properties.",
        )
}

val releaseBuildRequested = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("release", ignoreCase = true)
}

if (releaseBuildRequested && !hasReleaseSigning) {
    throw GradleException(
        "Android release signing configuration is missing. " +
            "Create the ignored android/key.properties file.",
    )
}

val releaseKeystoreFile = if (hasReleaseSigning) {
    file(signingProperty("storeFile"))
} else {
    null
}

if (releaseBuildRequested && releaseKeystoreFile?.isFile != true) {
    throw GradleException(
        "The Android release keystore configured in " +
            "android/key.properties was not found.",
    )
}

android {
    namespace = "pl.recipesforsoftware.dailystanza"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "pl.recipesforsoftware.dailystanza"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
                storeFile = releaseKeystoreFile
                storePassword = signingProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
