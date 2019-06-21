#!/bin/bash
set -eo pipefail
cd ..

DESTINATION='platform=iOS Simulator,name=iPhone 8,OS=latest'
WORKSPACE="orderMe.xcworkspace"
SDK="iphonesimulator"
SCHEME="orderMe";
XCTESTRUN_PATH=Jenkins/build/Build/Products/${SCHEME}_iphonesimulator*x86_64.xctestrun

build() {
    rm -rf Jenkins/build
    rm -rf Jenkins/reports
    mkdir -p Jenkins/build
    echo "Jenkins.sh: Building binaries"
    xcodebuild \
    -workspace "${WORKSPACE}" \
    -scheme "${SCHEME}" \
    -sdk "${SDK}" \
    -destination "${DESTINATION}" \
    -derivedDataPath ./Jenkins/build clean build-for-testing
}

run() {
    echo "Jenkins.sh: Start xctestrun"

    rm -rf Jenkins/build/reports

    xcodebuild test-without-building  \
    -xctestrun ${XCTESTRUN_PATH} \
    -destination "${DESTINATION}" | xcpretty -r junit -r html
}

build
run
