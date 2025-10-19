# Auto-Install Dependencies for React/JS Projects

A Bash script to automatically detect missing dependencies and devDependencies in your JavaScript/React project and install them.  
It scans your source code and test/config files, compares imports with `package.json`, and installs any missing packages with proper separation for dev vs production.

---

## Features

- Scans your `src/` folder for imports and requires.
- Normal imports → installed as `dependencies`.
- Test/config imports → installed as `devDependencies`.
- Handles scoped packages (e.g., `@mui/material`) and strips subpaths (e.g., `react-dom/client` → `react-dom`).
- Dry-run & confirmation prompt before installing anything.
- Works with modern React projects and most JS projects.

---

## Usage

1. Clone or copy the script to your project root:

```bash
curl -O https://raw.githubusercontent.com/lchsjji/auto-install-deps/main/auto-install.sh

```
2. Make the script executable:

```bash
chmod +x auto-install.sh
```

3. Run the script:

```bash
./auto-install.sh
```

4. The script will show what packages are missing and ask for confirmation before installing them.

---

## Requirements

- Bash shell (Git Bash, WSL, or Linux/macOS terminal)

- jq installed and available in your PATH (download jq)

- Node.js and npm installed

## Safety & Notes

- The script prompts for confirmation before installing anything, so you stay in control.

- Avoid running it on production-only servers, it’s designed for local development.

- Handles devDependencies automatically based on test/config files.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.
