# Google Java Format Plugin

一个简洁的 VS Code 扩展，用于运行 Google Java Format 工具格式化 Java 代码。支持 Google Style 和 AOSP (Android Open Source Project) 格式之间的快速切换。

## 特性

- ✅ **简洁直接**: 直接调用系统中的 google-java-format 工具
- ✅ **双重风格**: 支持 Google Style 和 AOSP 格式
- ✅ **一键切换**: 右键菜单快速切换格式风格
- ✅ **范围格式化**: 支持格式化选中的代码片段
- ✅ **轻量级**: 无需下载，依赖系统安装的工具

## 前置要求

需要在系统中安装`google-java-format`工具。推荐使用包管理器安装：

### macOS (Homebrew)

```bash
brew install google-java-format
```

### Ubuntu/Debian

```bash
sudo apt-get install google-java-format
```

### 手动安装

从 [Google Java Format Releases](https://github.com/google/google-java-format/releases) 下载 jar 文件，并创建启动脚本。

## Java 版本兼容性问题

⚠️ **重要提示**: Google Java Format 需要 Java 24 或更高版本运行，如果你的系统只有 Java 8，请参考以下解决方案：

### 🚀 快速安装脚本（推荐）

我们提供了一个自动安装脚本，可以自动检测和安装 Java 以及 Google Java Format：

```bash
# 下载并运行安装脚本
curl -fsSL https://raw.githubusercontent.com/rongwoxiangxiang/Google-Java-Format-Plugin/refs/heads/main/install-google-java-format.sh | bash

# 或者克隆仓库后运行
git clone https://github.com/rongwoxiangxiang/google-format-plugin.git
cd google-format-plugin
./install-google-java-format.sh
```

**脚本功能**:

- 自动检测当前 Java 版本
- 如果需要，安装 Java 24
- 安装 Google Java Format
- 配置环境变量
- 验证安装结果

### 方案 1: 使用旧版本 Google Java Format（Java 8 兼容）

如果必须使用 Java 8，可以下载兼容 Java 8 的旧版本：

```bash
# 创建工具目录
mkdir -p ~/.local/tool/google-java-format
mkdir -p ~/.local/bin/
cd ~/.local/tool/google-java-format

# 下载兼容Java 8的版本（如1.7版本）
wget https://github.com/google/google-java-format/releases/download/google-java-format-1.7/google-java-format-1.7-all-deps.jar


# 创建启动脚本
cd ~/.local/bin/
cat > google-java-format << 'EOF'
#!/bin/bash
java -jar ~/.local/tool/google-java-format/google-java-format-1.7-all-deps.jar "$@"
EOF

# 添加执行权限
chmod +x google-java-format

# 添加到PATH
export PATH="$HOME/.local/bin:$PATH"
```

### 方案 2: 安装 Java 24 + 对插件进行封装

```bash
# 1.使用Homebrew安装OpenJDK 24
brew install openjdk@24

# 2.创建包装bash，可以按需存放对应目录
touch ~/.local/bin/google-java-format

# 3.配置执行目录
"google-java-format.executable-path": "~/.local/bin/google-java-format"
```

```bash
> cat ~/.local/bin/google-java-format

#!/bin/bash
# Google Java Format wrapper script
# This script ensures google-java-format uses the correct Java version

#java24路径
export JAVA_HOME=/opt/homebrew/Cellar/openjdk/24.0.2/libexec/openjdk.jdk/Contents/Home
exec /opt/homebrew/bin/google-java-format "$@"
```

### 方案 3: 多 Java 版本管理

#### 使用 SDKMAN

```bash
# 安装SDKMAN
curl -s "https://get.sdkman.io" | bash
source ~/.sdkman/bin/sdkman-init.sh

# 安装Java 21
sdk install java 24.0.2

# 临时切换到Java 24
sdk use java 24.0.2

# 设为默认版本
sdk default java 24.0.2
```

#### 手动切换 Java 版本

```bash
# macOS - 创建Java版本切换脚本
echo 'alias java8="export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)"' >> ~/.zshrc
echo 'alias java24="export JAVA_HOME=$(/usr/libexec/java_home -v 24)"' >> ~/.zshrc

# 使用方法
java24  # 切换到Java 24
google-java-format --version  # 现在可以正常使用
java8   # 切回Java 8（如需要）
```

### 方案 4: VS Code 插件配置

如果使用了自定义路径或 jar 文件，在 VS Code 中配置：

```json
{
  "google-java-format.executable-path": "/path/to/your/google-java-format",
  // 或者直接使用jar文件
  "google-java-format.executable-path": "java -jar /path/to/google-java-format.jar"
}
```

### 验证安装

```bash
# 检查Java版本
java -version
javac -version

# 检查Google Java Format
google-java-format --version

# 测试格式化
echo "class Test{public static void main(String[]args){System.out.println(\"Hello\");}}" | google-java-format -
```

## 使用方法

### 设置为默认格式化工具

在 VS Code 设置中添加：

```json
{
  "[java]": {
    "editor.defaultFormatter": "google-java-format.google-java-format-plugin"
  }
}
```

### 格式化代码

1. **整个文件**: `Shift + Alt + F` (Windows/Linux) 或 `Shift + Option + F` (macOS)
2. **选中代码**: 选择代码后使用相同快捷键
3. **右键菜单**: 右键选择"格式化文档"或"格式化选择"

### 切换格式风格

- **方法 1**: 右键菜单 → "切换格式化风格（Google/AOSP）"
- **方法 2**: 命令面板 (`Ctrl+Shift+P`) → "切换格式化风格（Google/AOSP）"

## 配置选项

在 VS Code 设置中搜索 "google-java-format" 可以找到以下选项：

### `google-java-format.executable-path`

- **类型**: `string`
- **默认值**: `"google-java-format"`
- **描述**: Google Java Format 可执行文件路径。如果工具已添加到 PATH，使用默认值即可

### `google-java-format.style`

- **类型**: `string`
- **可选值**: `"google"`, `"aosp"`
- **默认值**: `"google"`
- **描述**: 代码格式化风格

### `google-java-format.extra-args`

- **类型**: `string`
- **默认值**: `""`
- **描述**: 传递给 Google Java Format 的额外命令行参数

## 配置示例

```json
{
  "google-java-format.executable-path": "/usr/local/bin/google-java-format",
  "google-java-format.style": "aosp",
  "google-java-format.extra-args": "--skip-sorting-imports"
}
```

## 格式风格对比

### Google Style (默认)

```java
class Example {
  void method() {
    if (condition) {
      doSomething();
    }
  }
}
```

### AOSP Style

```java
class Example {
    void method() {
        if (condition) {
            doSomething();
        }
    }
}
```

## 故障排除

### 常见问题

**问题**: 提示"无法启动 Google Java Format"
**解决**:

1. 确保已安装 google-java-format 工具
2. 检查`executable-path`配置是否正确
3. 验证工具是否在 PATH 中：`which google-java-format`
4. 检查 Java 版本：`java -version`（最新版需要 Java 24 支持）

**问题**: 格式化没有效果
**解决**:

1. 检查代码是否有语法错误
2. 查看 VS Code 输出面板的错误信息
3. 尝试在终端手动运行工具测试

**问题**: "UnsupportedClassVersionError" 或 Java 版本不兼容
**解决**:

1. 检查当前 Java 版本：`java -version`
2. 确保使用 Java 24+
3. 参考上面的"Java 版本兼容性问题"章节切换 Java 版本
4. 或下载兼容 Java 8 的旧版本 Google Java Format

**问题**: macOS 上 Homebrew 安装失败
**解决**:

```bash
# 先安装Java 24
brew install openjdk@24

# 设置环境变量
export JAVA_HOME=/usr/local/opt/openjdk@24

# 再安装google-java-format
brew install google-java-format
```

**问题**: 在 VS Code 中配置 jar 文件路径
**解决**:

```json
{
  "google-java-format.executable-path": "java -jar /full/path/to/google-java-format-x.x.x-all-deps.jar"
}
```

### 验证安装

在终端运行以下命令验证安装：

```bash
google-java-format --version
```

## 开发

### 本地开发

```bash
git clone https://github.com/rongwoxiangxiang/google-format-plugin.git
cd google-format-plugin
npm install
npm run compile
```

### 调试插件

#### 方式 1: 开发模式（推荐）

1. 在 VS Code 中打开插件项目目录
2. 确保已编译：`npm run compile`
3. 按 `F5` 启动扩展开发主机
4. 会打开一个新的 VS Code 窗口（标题显示"[扩展开发主机]"）
5. 在新窗口中打开`test/Example.java`文件测试

#### 方式 2: 打包安装

```bash
# 安装打包工具
npm install -g vsce

# 打包扩展
vsce package

# 会生成 google-java-format-plugin-1.0.0.vsix 文件
# 在VS Code中: Extensions → Install from VSIX → 选择生成的.vsix文件
```

#### 方式 3: 本地符号链接安装

```bash
# macOS/Linux
ln -s "$(pwd)" ~/.vscode/extensions/google-java-format-plugin

# Windows
mklink /D "%USERPROFILE%\.vscode\extensions\google-java-format-plugin" "$(pwd)"
```

#### 测试步骤

1. 打开`test/Example.java`文件（格式混乱的 Java 代码）
2. 使用 `Shift + Alt + F` 格式化
3. 测试切换格式风格：右键 → "切换格式化风格（Google/AOSP）"
4. 再次格式化，观察风格变化

#### 调试技巧

- 查看输出面板: View → Output → 选择"Google Java Format"
- 使用开发者工具: Help → Toggle Developer Tools
- 设置断点: 在`src/extension.ts`中设置断点进行调试

## 致谢

本项目参考了以下开源项目：

- [ilkka/vscode-google-java-format](https://github.com/ilkka/vscode-google-java-format) - 简洁的实现思路
- [JoseVSeb/google-java-format-for-vs-code](https://github.com/JoseVSeb/google-java-format-for-vs-code) - 功能特性参考
- [Google Java Format](https://github.com/google/google-java-format) - 核心格式化工具

## 许可证

本项目使用 [Apache License 2.0](LICENSE.md) 许可证。

详细许可证内容请查看 [LICENSE.md](LICENSE.md) 文件。

---

**享受使用！** 🚀
