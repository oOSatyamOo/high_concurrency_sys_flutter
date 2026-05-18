plugins {
    id("com.android.application")
    id("kotlin-android")
    // @AETHER: Google Services plugin processes google-services.json for Firebase config.
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.github.oOSatyamOo.aether_cost_opt"
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
        applicationId = "com.github.oOSatyamOo.aether_cost_opt"
        // @AETHER: minSdk 23 required by Firebase Android SDK.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // @AETHER: Firebase BoM ensures all Firebase library versions are mutually compatible.
    // Never specify individual Firebase lib versions when using BoM.
    implementation(platform("com.google.firebase:firebase-bom:34.13.0"))

    // @AETHER: Only Firestore — Aether's entire data layer is Firestore-backed.
    // No Analytics added to minimize APK size and unnecessary network calls.
    implementation("com.google.firebase:firebase-firestore")
}
