# Without FVM

gen:
	@echo "* Running build runner *"
	@dart run build_runner build --delete-conflicting-outputs

init:
	@echo "* Getting latest dependencies *"
	@flutter pub get
	@echo "* Running build runner *"
	@dart run build_runner build --delete-conflicting-outputs
	@dart pub run intl_utils:generate