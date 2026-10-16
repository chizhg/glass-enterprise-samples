#!/bin/bash

# Fail on any error.
set -e

# Make sure the right tools are installed
echo y | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "build-tools;28.0.3"
${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --install "ndk;21.0.6113669" "cmake;3.10.2.4988404"

# Pre-populate org.webrtc:google-webrtc:1.0.30039 (originally hosted on defunct JCenter)
WEBRTC_M2_DIR="${HOME}/.m2/repository/org/webrtc/google-webrtc/1.0.30039"
mkdir -p "${WEBRTC_M2_DIR}"
cat > "${WEBRTC_M2_DIR}/google-webrtc-1.0.30039.pom" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.webrtc</groupId>
  <artifactId>google-webrtc</artifactId>
  <version>1.0.30039</version>
  <packaging>aar</packaging>
</project>
EOF

curl -fSL --retry 3 -o "${WEBRTC_M2_DIR}/google-webrtc-1.0.30039.aar" \
  "https://maven.aliyun.com/repository/jcenter/org/webrtc/google-webrtc/1.0.30039/google-webrtc-1.0.30039.aar" || \
curl -fSL --retry 3 -o "${WEBRTC_M2_DIR}/google-webrtc-1.0.30039.aar" \
  "https://repo.huaweicloud.com/repository/maven/org/webrtc/google-webrtc/1.0.30039/google-webrtc-1.0.30039.aar" || \
curl -fSL --retry 3 -o "${WEBRTC_M2_DIR}/google-webrtc-1.0.30039.aar" \
  "https://repo1.maven.org/maven2/com/infobip/google-webrtc/1.0.0035529/google-webrtc-1.0.0035529.aar"

mkdir -p "${HOME}/.gradle/init.d"
cat > "${HOME}/.gradle/init.d/jcenter-fallback.gradle" << 'EOF'
allprojects {
  buildscript {
    repositories {
      mavenLocal()
      google()
      mavenCentral()
      maven { url "https://maven.aliyun.com/repository/jcenter" }
    }
  }
  repositories {
    mavenLocal()
    google()
    mavenCentral()
    maven { url "https://maven.aliyun.com/repository/jcenter" }
  }
}
EOF

cd ${KOKORO_ARTIFACTS_DIR}/github/glass-enterprise-samples

( cd Camera2Sample                && ./gradlew build )
( cd CardSample                   && ./gradlew build )
( cd GallerySample                && ./gradlew build )
( cd GestureLibrarySample         && ./gradlew build )
( cd QRCodeScannerSample          && ./gradlew build )
( cd VoiceRecognitionSample       && ./gradlew build )
( cd WebRTCSample                 && ./gradlew build )
( cd NotesSample                  && ./gradlew build )
( cd VoiceCommandsReloadingSample && ./gradlew build )

