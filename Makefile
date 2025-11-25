.PHONY: gen init release-android ln ci-set-version-suffix aux-generate-android-keystore


gen:
	@echo "* Running build runner *"
	@dart run build_runner build --delete-conflicting-outputs

ln:
	@echo "* Generating localizations *"
	@dart run intl_utils:generate

init:
	@echo "* Running flutter clean *"
	@flutter clean
	@echo "* Getting latest dependencies *"
	@flutter pub get
	@echo "* Running build runner *"
	@dart run build_runner build --delete-conflicting-outputs
	@dart pub run intl_utils:generate

.dart_tool/package_config.json: pubspec.yaml pubspec.lock
	@echo "* Resolving dependencies... *"
	@flutter pub get 2>&1 | \
		grep -v 'untranslated message' | \
		grep -v 'To see a detailed report' | \
		grep -v 'untranslated-messages-file' | \
		grep -v 'This will generate' | cat
	@echo "* Dependencies resolved. *"

lib/common/localization/generated/l10n.dart: .dart_tool/package_config.json lib/common/localization/arb/*.arb
	@echo "* Generating localization... *"
	@dart run intl_utils:generate 2>&1 | \
		grep -v 'untranslated message' | \
		grep -v 'To see a detailed report' | \
		grep -v 'untranslated-messages-file' | \
		grep -v 'This will generate' | cat
	@flutter gen-l10n 2>&1 | \
		grep -v 'untranslated message' | \
		grep -v 'To see a detailed report' | \
		grep -v 'untranslated-messages-file' | \
		grep -v 'This will generate' | cat
	@echo "* Localization generated. *"

.dart_tool/build/entrypoint/build.dart: lib/common/localization/generated/l10n.dart
	@echo "* Starting code generation... *"
	@dart run build_runner build --delete-conflicting-outputs
	@$(MAKE) -C plugins/vpn_plugin gen
	@echo "* Code generation successful *"