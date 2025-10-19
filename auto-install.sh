# === CONFIGURATION ===
SOURCE_DIR="src"            # folder to scan for imports
PKG_FILE="package.json"     # path to package.json

# === 1. Find all imported/required packages in normal code ===
normal_imports=$(grep -rohP "(?<=from ['\"])[^'\"]+|(?<=require\(['\"])[^'\"]+" "$SOURCE_DIR" \
  | grep -vE "^(\.|/)" \
  | grep -vE "(\.test\.|\.spec\.|__tests__|\.eslintrc|jest.config|webpack.config|vite.config)" \
  | sed 's|^\(@[^/]\+/[^/]\+\).*|\1|' \
  | sed 's|/.*||' \
  | sort -u)

# === 2. Find imports in test/dev files (devDependencies) ===
dev_imports=$(grep -rohP "(?<=from ['\"])[^'\"]+|(?<=require\(['\"])[^'\"]+" "$SOURCE_DIR" \
  | grep -vE "^(\.|/)" \
  | grep -E "(\.test\.|\.spec\.|__tests__|\.eslintrc|jest.config|webpack.config|vite.config)" \
  | sed 's|^\(@[^/]\+/[^/]\+\).*|\1|' \
  | sed 's|/.*||' \
  | sort -u)

# === 3. Extract existing dependencies ===
installed_packages=$(jq -r '.dependencies // {} | keys[]' "$PKG_FILE")
installed_dev_packages=$(jq -r '.devDependencies // {} | keys[]' "$PKG_FILE")

# === 4. Find missing normal dependencies ===
missing_packages=()
for pkg in $normal_imports; do
  if ! grep -qx "$pkg" <<< "$installed_packages" && ! grep -qx "$pkg" <<< "$installed_dev_packages"; then
    missing_packages+=("$pkg")
  fi
done

# === 5. Find missing devDependencies ===
missing_dev_packages=()
for pkg in $dev_imports; do
  if ! grep -qx "$pkg" <<< "$installed_packages" && ! grep -qx "$pkg" <<< "$installed_dev_packages"; then
    missing_dev_packages+=("$pkg")
  fi
done

# === 6. Dry-run: show what will be installed ===
if [ ${#missing_packages[@]} -gt 0 ] || [ ${#missing_dev_packages[@]} -gt 0 ]; then
  echo "🚀 The following packages will be installed:"
  if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "  Dependencies: ${missing_packages[*]}"
  fi
  if [ ${#missing_dev_packages[@]} -gt 0 ]; then
    echo "  DevDependencies: ${missing_dev_packages[*]}"
  fi

  # === 7. Confirm before installing ===
  read -p "Proceed with installation? [y/N]: " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    if [ ${#missing_packages[@]} -gt 0 ]; then
      npm install "${missing_packages[@]}"
    fi
    if [ ${#missing_dev_packages[@]} -gt 0 ]; then
      npm install --save-dev "${missing_dev_packages[@]}"
    fi
    echo "✅ Installation complete."
  else
    echo "⚠️ Installation canceled by user."
  fi
else
  echo "✅ All imports are already declared in package.json."
fi
