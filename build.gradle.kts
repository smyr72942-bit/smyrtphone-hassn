plugins {

    id("com.android.application")

    id("kotlin-android")

    // ✅ تفعيل Google Services Plugin داخل التطبيق

    id("com.google.gms.google-services")

    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.

    id("dev.flutter.flutter-gradle-plugin")

}

android {

    namespace = "com.fursak.app"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = "27.0.12077973" // ✅ هذا هو التعديل المهم

    compileOptions {

        sourceCompatibility = JavaVersion.VERSION_11

        targetCompatibility = JavaVersion.VERSION_11

    }

    kotlinOptions {

        jvmTarget = JavaVersion.VERSION_11.toString()

    }

    defaultConfig {

        applicationId = "com.fursak.app"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName

    }

    buildTypes {

        release {

            signingConfig = signingConfigs.getByName("debug")

        }

    }

}

flutter {

    source = "../.."

}

dependencies {

    // ✅ مكتبة Firebase الأساسية

    implementation("com.google.firebase:firebase-analytics")

    // ✅ مكتبات إضافية حسب استخدامك

    implementation("com.google.firebase:firebase-auth")

    implementation("com.google.firebase:firebase-firestore")

    implementation("com.google.firebase:firebase-storage")

    implementation("com.google.firebase:firebase-messaging")

    // ✅ مكتبات Flutter و Kotlin

    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7")

}