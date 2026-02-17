.PHONY: build clean install

APP_NAME = LinkDrop
BUILD_DIR = $(APP_NAME).app
SOURCES = Sources/LinkDropApp.swift

build:
	@mkdir -p $(BUILD_DIR)/Contents/MacOS $(BUILD_DIR)/Contents/Resources
	swiftc -parse-as-library -target arm64-apple-macosx13.0 \
		-framework SwiftUI -framework AppKit \
		-o $(BUILD_DIR)/Contents/MacOS/$(APP_NAME) $(SOURCES)
	@cp Info.plist $(BUILD_DIR)/Contents/Info.plist
	@cp icon.svg $(BUILD_DIR)/Contents/Resources/ 2>/dev/null || true
	@echo "Built $(BUILD_DIR)"

clean:
	rm -rf $(BUILD_DIR) $(APP_NAME).iconset icon.svg.png

install: build
	@cp -R $(BUILD_DIR) /Applications/
	@echo "Installed to /Applications/$(BUILD_DIR)"

run: build
	@open $(BUILD_DIR)
