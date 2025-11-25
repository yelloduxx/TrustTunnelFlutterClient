#!/bin/bash

set -x

# Moving to a folder with scripts and move to the root directory
cd $(dirname $0)
cd ../..

build_channel="$1"
if [ "$build_channel" == "" ]; then
    echo "The build channel not specified"; exit 1
fi

project_dir="$2"
if [[ "${project_dir}" == "" ]]; then
  echo "The project directory path not specified"; exit 1
fi



# Configure files for "pod install"
if [ "$build_channel" == "prenightly" ]; then
    echo "parameters.buildChannel = BuildChannel::PreNightly" > custom.local
elif [ "$build_channel" == "nightly" ]; then
    echo "parameters.buildChannel = BuildChannel::Nightly" > custom.local
elif [ "$build_channel" == "beta" ]; then
    echo "parameters.buildChannel = BuildChannel::Beta" > custom.local
elif [ "$build_channel" == "rc" ]; then
    echo "parameters.buildChannel = BuildChannel::Rc" > custom.local
else
    echo "parameters.buildChannel = BuildChannel::Release" > custom.local
fi
echo "parameters.backendType = BackendType::Prod" >> custom.local

# Remove the GPR_KEY secret when native lib will be published
export GPR_KEY="${bamboo_githubPublicRepoPassword}"

if [[ -z "$GPR_KEY" ]]; then
    echo "ERROR: GPR_KEY Bamboo secret is empty or not defined!"
    exit 1
fi

echo "${bamboo_fastlaneAppStoreApiInfoSecret}" | base64 --decode > "${project_dir}/ios/fastlane/AppStoreApiInfo.json"
echo "${bamboo_fastlaneEnvSecret}" | base64 --decode > "${project_dir}/ios/fastlane/.env"

# Configure project's dependencies
make .dart_tool/package_config.json

# Configure bundler
cd ios
bundle config set --local path '.bundle/vendor'
bundle install
if [ $? -eq 1 ]; then exit 1; fi


bundle exec pod install --repo-update
if [ $? -eq 1 ]; then exit 1; fi
