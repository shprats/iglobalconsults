# IDE Setup Guide for GlobalHealth Connect

## Recommended IDE: **VS Code / Cursor** (You're already using Cursor!)

**Why VS Code/Cursor is perfect for this project:**
- ✅ Excellent Flutter support
- ✅ Great Python/FastAPI support
- ✅ Multi-language workspace support
- ✅ Built-in Git integration
- ✅ Free and lightweight
- ✅ Extensive extension ecosystem
- ✅ Works seamlessly on macOS

## Installation Steps

### 1. Install Flutter

**Option A: Using Homebrew (Recommended)**
```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Flutter
brew install --cask flutter

# Verify installation
flutter doctor
```

**Option B: Manual Installation**
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add to ~/.zshrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Reload shell
source ~/.zshrc

# Verify
flutter doctor
```

### 2. Install Required VS Code/Cursor Extensions

Open Cursor/VS Code and install these extensions:

**Essential Extensions:**
1. **Flutter** (by Dart Code) - Flutter development support
2. **Dart** (by Dart Code) - Dart language support
3. **Python** (by Microsoft) - Python development
4. **Pylance** (by Microsoft) - Python language server
5. **FastAPI** (by FastAPI) - FastAPI snippets and support
6. **SQLAlchemy** (by SQLTools) - Database tools
7. **GitLens** (by GitKraken) - Enhanced Git capabilities
8. **Error Lens** (by Alexander) - Inline error highlighting
9. **Thunder Client** (by Ranga Vadhineni) - API testing (alternative to Postman)

**Optional but Recommended:**
- **REST Client** - Test APIs directly in editor
- **YAML** - For configuration files
- **Docker** - If using containers
- **Markdown All in One** - Better markdown support

### 3. Configure Workspace

Create a workspace file for better organization:

**File: `iglobalconsults.code-workspace`**
```json
{
  "folders": [
    {
      "path": ".",
      "name": "GlobalHealth Connect"
    },
    {
      "path": "./mobile",
      "name": "Mobile App (Flutter)"
    },
    {
      "path": "./backend",
      "name": "Backend API (FastAPI)"
    },
    {
      "path": "./web-dashboard",
      "name": "Web Dashboard (React/Next.js)"
    },
    {
      "path": "./database",
      "name": "Database Schemas"
    }
  ],
  "settings": {
    "files.exclude": {
      "**/__pycache__": true,
      "**/*.pyc": true,
      "**/.dart_tool": true,
      "**/build": true,
      "**/node_modules": true
    },
    "python.defaultInterpreterPath": "${workspaceFolder}/backend/venv/bin/python",
    "python.analysis.extraPaths": [
      "${workspaceFolder}/backend"
    ],
    "dart.flutterSdkPath": null, // Auto-detect
    "[python]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "ms-python.black-formatter"
    },
    "[dart]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "Dart-Code.dart-code"
    }
  }
}
```

### 4. Flutter Setup Commands

After installing Flutter, run:

```bash
# Accept licenses
flutter doctor --android-licenses

# Install iOS development tools (if needed)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Verify everything
flutter doctor -v
```

### 5. Python Environment Setup

```bash
cd backend

# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# In VS Code/Cursor, select this interpreter:
# Cmd+Shift+P → "Python: Select Interpreter" → Choose venv/bin/python
```

## Quick Start in Cursor/VS Code

1. **Open the workspace:**
   ```bash
   cd /Users/pratik/Documents/iglobalconsults
   cursor .  # or: code .
   ```

2. **Open Flutter project:**
   - Open `mobile` folder
   - Cursor will detect Flutter and prompt to install extensions

3. **Open Backend project:**
   - Open `backend` folder
   - Select Python interpreter (venv)

4. **Use Multi-root Workspace:**
   - File → Open Workspace from File
   - Select `iglobalconsults.code-workspace`

## Alternative IDEs (If you prefer)

### Android Studio
- **Best for:** Pure Flutter development
- **Pros:** Excellent Flutter tools, built-in emulator
- **Cons:** Heavy, Java-focused, not great for Python

### PyCharm Professional
- **Best for:** Python/FastAPI backend
- **Pros:** Excellent Python support, database tools
- **Cons:** Paid, not great for Flutter

### IntelliJ IDEA Ultimate
- **Best for:** Everything (paid)
- **Pros:** Supports all languages
- **Cons:** Expensive, can be heavy

## Recommended Setup: VS Code/Cursor

**For this multi-platform project, VS Code/Cursor is the clear winner because:**
- Handles Flutter, Python, and React equally well
- Lightweight and fast
- Free and open-source
- Excellent extension ecosystem
- Great Git integration
- You're already using Cursor!

## Next Steps After Setup

1. ✅ Install Flutter
2. ✅ Install VS Code/Cursor extensions
3. ✅ Set up Python virtual environment
4. ✅ Open workspace in Cursor
5. 🚀 Start coding!

