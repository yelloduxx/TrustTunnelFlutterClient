# VPN OSS GUI Client apps

После установки нужно выполнить следующие команды:

из корневой папки проекта:

make init

из папки плагина plugins/vpn_plugin:

flutter pub get

flutter pub run pigeon \
--input pigeons/api.dart \
--swift_out macos/Classes/PlatformApi.g.swift

flutter pub run pigeon \
--input pigeons/api.dart \
--swift_out ios/Classes/PlatformApi.g.swift
