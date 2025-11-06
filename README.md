# VPN OSS GUI Client apps

После установки нужно выполнить следующие команды:

из корневой папки проекта:

make init

из папки плагина plugins/vpn_plugin:

flutter pub get
make gen

### Android specific instructions

Place your Github token for accessing Github Packages into `gpr.key` property of ~/.gradle/gradle.properties
