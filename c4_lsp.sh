#!/usr/bin/env bash

# Define the repository URL and the target directory
REPO_URL="https://gitlab.com/systemticks/c4-dsl-language-server"
TARGET_DIR="$HOME/.local/share/lsp-servers/c4-dsl-language-server"
if [ -d "$TARGET_DIR" ]; then
  rm -rf "$TARGET_DIR/*"
fi

mkdir -p "$TARGET_DIR"

# Create a temporary directory for cloning the repository
TEMP_DIR=$(mktemp -d)

# Cleanup function to remove the temporary directory
cleanup() {
  rm -rf "$TEMP_DIR"
}

# Ensure the cleanup function is called on script exit
#trap cleanup EXIT

# Clone the repository into the temporary directory
git clone "$REPO_URL" "$TEMP_DIR"

# Navigate to the temporary directory
cd "$TEMP_DIR" || exit

# Create .tool-versions file to specify the correct Java version
echo "java corretto-17" > .tool-versions
echo "gradle 7.5.1" >> .tool-versions

# Ensure the correct Java version is used
mise install

# Build and deploy the language server to the target directory using the specific Gradle version
./gradlew build

# Locate the tar file and extract it into the target directory
TAR_FILE=$(find "$TEMP_DIR/build/distributions" -name "c4-language-server.tar")
if [ -f "$TAR_FILE" ]; then
  echo "Extracting $TAR_FILE to $TARGET_DIR..."
  tar -xvf "$TAR_FILE" -C "$TARGET_DIR" --strip-components=1
else
  echo "Error: tar file not found in build/distributions"
  exit 1
fi

echo "C4 Language Server LSP built successfully and stored in $TARGET_DIR"
