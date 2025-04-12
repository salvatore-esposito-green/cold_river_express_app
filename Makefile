gen_icons:
	dart run flutter_launcher_icons

clean:
	flutter clean

clean_ios:
	rm -rf ios/Flutter/Flutter.framework && rm ios/Podfile.lock && rm -rf ios/Pods

build_ios:
	@version_with_build=$$(grep '^version:' pubspec.yaml | awk '{print $$2}') ; \
	version=$${version_with_build%%+*} ; \
	build=$${version_with_build#*+} ; \
	flutter build ios --release --build-name=$$version --build-number=$$build

build_android:
	@version_with_build=$$(grep '^version:' pubspec.yaml | awk '{print $$2}') ; \
	version=$${version_with_build%%+*} ; \
	build=$$(echo $${version_with_build#*+} | xargs) ; \
	if [ -z "$$build" ]; then \
		echo "Error: build number is empty" && exit 1; \
	fi; \
	flutter build apk --release --build-name=$$version --build-number=$$build