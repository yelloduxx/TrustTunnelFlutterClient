#!/bin/bash

set -x -e

# Moving to a folder with scripts and move to the root directory
cd $(dirname $0)
cd ../..

build_type="$1"
if [ "$build_type" == "" ]; then
    echo "The build type not specified"; exit 1
fi

upload_symbols="$2"
if [ "$upload_symbols" == "" ]; then
    echo "The 'upload symbols' state not specified"; exit 1
fi



bundle exec fastlane sync_certs_and_profiles type:"$build_type"
if [ "$build_type" != "appstore" ]; then
    echo "Build type is not 'appstore', so we need to download 'appstore' profiles to build an app, also."
    echo "That's an 'xcodebuild' command feature which is used by fastlane to build an app."
    bundle exec fastlane sync_certs_and_profiles type:appstore readonly:true
fi

make .dart_tool/build/entrypoint/build.dart

bundle exec fastlane build_ipa type:"$build_type" upload_symbols:"$upload_symbols"
