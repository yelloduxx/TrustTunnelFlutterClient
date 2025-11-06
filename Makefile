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

vec:
	@echo "* Generating vectors from svg *"
	@vector_graphics_compiler --input-dir=assets/svg --out-dir=assets/vectors

ln:
	@echo "* Generating localizations *"
	@dart run intl_utils:generate
