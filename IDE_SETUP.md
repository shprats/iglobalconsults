# IDE Setup Guide for GlobalHealth Connect

## Recommended IDE: **Visual Studio Code (VS Code)**

**Why VS Code?**
- ✅ Excellent Flutter/Dart support (official extensions)
- ✅ Great Python support (FastAPI, Django, etc.)
- ✅ SQL syntax highlighting
- ✅ Multi-language project support
- ✅ Lightweight and fast
- ✅ Free and open-source
- ✅ Excellent Git integration
- ✅ Integrated terminal
- ✅ Works great on macOS

## Installation Steps

### 1. Install VS Code

**Option A: Download from website (Recommended)**
1. Go to https://code.visualstudio.com/
2. Download macOS version
3. Drag to Applications folder
4. Open VS Code

**Option B: Install via Homebrew**
```bash
brew install --cask visual-studio-code
```

### 2. Install Required VS Code Extensions

Open VS Code and install these extensions:

**For Flutter Development:**
- `Dart` (by Dart Code)
- `Flutter` (by Dart Code)

**For Python/Backend Development:**
- `Python` (by Microsoft)
- `Pylance` (by Microsoft) - Python language server
- `Python Docstring Generator` (optional)

**For Database:**
- `PostgreSQL` (by Chris Kolkman)
- `SQLTools` (by Matheus Teixeira)

**General/Useful:**
- `GitLens` - Enhanced Git capabilities
- `Error Lens` - Inline error highlighting
- `Better Comments` - Better comment highlighting
- `Material Icon Theme` - Better file icons
- `Prettier` - Code formatter
- `YAML` - YAML file support

**Quick Install Command:**
```bash
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ckolkman.vscode-postgres
code --install-extension eamodio.gitlens
```

### 3. Open Project in VS Code

```bash
cd /Users/pratik/Documents/iglobalconsults
code .
```

Or:
1. Open VS Code
2. File → Open Folder
3. Navigate to `/Users/pratik/Documents/iglobalconsults`
4. Click "Open"

### 4. Configure VS Code Workspace Settings

Create `.vscode/settings.json` in the project root:

```json
{
  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true,
    "**/.dart_tool": true,
    "**/build": true
  },
  "python.defaultInterpreterPath": "${workspaceFolder}/backend/venv/bin/python",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "dart.flutterSdkPath": null,  // Will auto-detect if Flutter is in PATH
  "[python]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "ms-python.black-formatter"
  },
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "Dart-Code.dart-code"
  },
  "[yaml]": {
    "editor.formatOnSave": true
  }
}
```

## Alternative IDE Options

### Android Studio (For Flutter Only)
- **Pros:** Official Flutter support, full IDE features
- **Cons:** Heavy, mainly for mobile development
- **Best for:** If you only want to work on Flutter

### IntelliJ IDEA Ultimate
- **Pros:** Excellent for both Flutter and Python
- **Cons:** Paid (free trial), heavier than VS Code
- **Best for:** Enterprise development

### PyCharm + Android Studio
- **Pros:** Best-in-class for Python and Flutter separately
- **Cons:** Need two IDEs, not ideal for monorepo

## Recommended Setup: VS Code

For this project structure (Flutter + Python FastAPI), **VS Code is the best choice** because:
1. You can work on both Flutter and Python in one IDE
2. Excellent extensions for both languages
3. Lightweight and fast
4. Great for multi-language projects
5. Free and well-maintained

## Next Steps After IDE Setup

1. Install Flutter (see FLUTTER_SETUP.md)
2. Set up Python virtual environment
3. Configure VS Code workspace
4. Start developing!

