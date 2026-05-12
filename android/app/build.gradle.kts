plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.naviga_operator"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.naviga_operator"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Ignore stray desktop.ini if sync tools drop it next to .so files (common under Google Drive).
    packaging {
        jniLibs {
            excludes += "**/desktop.ini"
        }
    }
}

// Strip runs on merged_native_libs before APK packaging; remove junk files after merge, before strip.
tasks.configureEach {
    val stripNative = name.startsWith("strip") && name.endsWith("DebugSymbols")
    if (!stripNative) return@configureEach

    doFirst {
        val flutterProjectDir = rootProject.projectDir.parentFile
        val mergedRoot =
            flutterProjectDir.resolve("build/app/intermediates/merged_native_libs")
        if (!mergedRoot.exists()) return@doFirst

        mergedRoot.walkTopDown()
            .filter { it.isFile && it.name.equals("desktop.ini", ignoreCase = true) }
            .forEach { file ->
                logger.lifecycle(
                    "Removing stray desktop.ini before native strip: {}",
                    file.absolutePath,
                )
                file.delete()
            }
    }
}

flutter {
    source = "../.."
}
