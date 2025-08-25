#!/bin/bash

# Copyright 2025 Google Java Format Plugin Team
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Google Java Format 安装脚本
# 适用于有Java版本兼容性问题的用户

set -e

echo "🚀 Google Java Format 安装脚本"
echo "================================"

# 支持环境变量控制自动安装
# 设置 AUTO_INSTALL=1 可以跳过所有确认提示
if [ "${AUTO_INSTALL:-0}" = "1" ]; then
    echo "🤖 检测到自动安装模式 (AUTO_INSTALL=1)"
fi

# 检查操作系统
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

echo "检测到操作系统: $OS"

# 检查当前Java版本并确定安装策略
check_java_version() {
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
        echo "当前Java版本: $JAVA_VERSION"
        
        # 解析主版本号
        if [[ $JAVA_VERSION == 1.8* ]]; then
            MAJOR_VERSION=8
        else
            MAJOR_VERSION=$(echo $JAVA_VERSION | cut -d'.' -f1)
        fi
        
        # 根据Java版本确定安装策略
        if [ "$MAJOR_VERSION" -eq 8 ]; then
            echo "✅ 检测到Java 8，将安装兼容版本的Google Java Format 1.7"
            INSTALL_STRATEGY="java8"
            return 0
        elif [ "$MAJOR_VERSION" -eq 24 ]; then
            echo "✅ 检测到Java 24，将安装最新版本的Google Java Format"
            INSTALL_STRATEGY="java24"
            return 0
        else
            echo "⚠️  检测到Java $MAJOR_VERSION"
            echo "⚠️  目前脚本仅支持Java 8和Java 24的自动安装"
            echo "⚠️  请参考README.md中的手动安装指南"
            INSTALL_STRATEGY="manual"
            return 1
        fi
    else
        echo "❌ 未检测到Java，请先安装Java"
        return 1
    fi
}

# 已删除install_java11函数，现在使用版本特定的安装策略

# 安装Google Java Format
install_google_java_format() {
    echo ""
    echo "正在安装Google Java Format..."
    
    if [ "$OS" = "macos" ]; then
        if command -v brew &> /dev/null; then
            brew install google-java-format
            echo "✅ Google Java Format安装完成"
        else
            echo "❌ 请先安装Homebrew"
            exit 1
        fi
    elif [ "$OS" = "linux" ]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y google-java-format
            echo "✅ Google Java Format安装完成"
        else
            # 手动安装
            install_compatible_version
        fi
    fi
}

# 根据Java版本安装对应的Google Java Format版本
install_compatible_version() {
    echo ""
    echo "根据Java版本安装兼容的Google Java Format..."
    
    # 创建安装目录
    INSTALL_DIR="$HOME/.local/tool/google-java-format"
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    
    # 根据Java版本选择对应的版本
    if [ "$INSTALL_STRATEGY" = "java8" ]; then
        # Java 8 使用 1.7 版本
        VERSION="1.7"
        echo "为Java 8安装Google Java Format $VERSION..."
        JAR_FILE="google-java-format-${VERSION}-all-deps.jar"
        DOWNLOAD_URL="https://github.com/google/google-java-format/releases/download/google-java-format-${VERSION}/$JAR_FILE"
    elif [ "$INSTALL_STRATEGY" = "java24" ]; then
        # Java 24 使用最新版本
        VERSION="1.28.0"
        echo "为Java 24安装Google Java Format $VERSION..."
        JAR_FILE="google-java-format-${VERSION}-all-deps.jar"
        DOWNLOAD_URL="https://github.com/google/google-java-format/releases/download/v${VERSION}/$JAR_FILE"
    else
        echo "❌ 不支持的安装策略: $INSTALL_STRATEGY"
        return 1
    fi

    echo "文件下载位置: $INSTALL_DIR/$JAR_FILE"
    
    # 检查文件是否已存在
    if [ -f "$INSTALL_DIR/$JAR_FILE" ]; then
        echo "✅ $JAR_FILE 已存在，跳过下载"
    else
        echo "正在下载 $JAR_FILE ..."
        if curl -L -o "$INSTALL_DIR/$JAR_FILE" "$DOWNLOAD_URL"; then
            echo "✅ 下载完成"
        else
            echo "❌ 下载失败，请检查网络连接或手动下载"
            return 1
        fi
    fi

    # 创建启动脚本
    cat > "$BIN_DIR/google-java-format" << EOF
#!/bin/bash
# Google Java Format v$VERSION for Java $MAJOR_VERSION
java -jar $INSTALL_DIR/$JAR_FILE "\$@"
EOF
    
    chmod +x "$BIN_DIR/google-java-format"

    echo "启动脚本内容: "
    cat "$BIN_DIR/google-java-format"

    # 添加到PATH
    SHELL_RC=""
    if [ -n "$ZSH_VERSION" ] || [ -n "$zsh" ] || [[ $SHELL == *"zsh"* ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ] || [[ $SHELL == *"bash"* ]]; then
        SHELL_RC="$HOME/.bash_profile"
    else
        SHELL_RC="$HOME/.profile"
    fi
    
    # 检查PATH是否已包含该目录
    if ! echo "$PATH" | grep -q "$BIN_DIR"; then
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
        echo "✅ 已添加 $BIN_DIR 到PATH"
    fi

    echo "✅ Google Java Format v$VERSION 安装完成"
    echo "安装路径: $BIN_DIR/google-java-format"
    echo "请运行以下命令重新加载配置："
    echo "source $SHELL_RC"
}

# 验证安装
verify_installation() {
    echo ""
    echo "验证安装..."
    
    if command -v google-java-format &> /dev/null; then
        VERSION=$(google-java-format --version 2>&1 || echo "未知版本")
        echo "✅ Google Java Format已安装: $VERSION"
        
        # 测试格式化
        echo "测试格式化功能..."
        TEST_JAVA="class Test{public static void main(String[]args){System.out.println(\"Hello\");}}"
        FORMATTED=$(echo "$TEST_JAVA" | google-java-format - 2>/dev/null || echo "格式化失败")
        
        if [ "$FORMATTED" != "格式化失败" ]; then
            echo "✅ 格式化功能正常"
        else
            echo "⚠️  格式化功能可能有问题"
        fi
    else
        echo "❌ Google Java Format未正确安装"
    fi
}

# 检测是否在管道中运行
is_piped() {
    [ ! -t 0 ]  # 检查标准输入是否不是终端
}

# 安全的用户输入函数
safe_read() {
    local prompt="$1"
    local default="$2"
    
    if [ "${AUTO_INSTALL:-0}" = "1" ]; then
        echo "$prompt"
        echo "🤖 自动安装模式，使用默认选择: $default"
        REPLY="$default"
    elif is_piped; then
        echo "$prompt"
        echo "📡 检测到通过管道执行，使用默认选择: $default"
        REPLY="$default"
    else
        read -p "$prompt" -n 1 -r < /dev/tty
        echo
    fi
}

# 主流程
main() {
    echo ""
    
    # 检查Java版本和安装策略
    check_java_version
    JAVA_CHECK_RESULT=$?
    
    if [ $JAVA_CHECK_RESULT -eq 0 ]; then
        # Java版本兼容，询问是否安装
        if [ "$INSTALL_STRATEGY" = "java8" ]; then
            echo ""
            safe_read "是否安装兼容Java 8的Google Java Format 1.7版本? (y/n): " "y"
        elif [ "$INSTALL_STRATEGY" = "java24" ]; then
            echo ""
            safe_read "是否安装适用于Java 24的最新Google Java Format? (y/n): " "y"
        fi
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # 根据操作系统和安装策略选择安装方式
            if [ "$INSTALL_STRATEGY" = "java24" ] && command -v brew &> /dev/null && [ "$OS" = "macos" ]; then
                echo "使用Homebrew安装最新版本..."
                install_google_java_format
            elif [ "$INSTALL_STRATEGY" = "java24" ] && command -v apt-get &> /dev/null && [ "$OS" = "linux" ]; then
                echo "使用包管理器安装最新版本..."
                install_google_java_format
            else
                echo "使用兼容版本安装方式..."
                install_compatible_version
            fi
            
            verify_installation
        else
            echo "跳过安装，你可以稍后手动安装"
        fi
    else
        # Java版本不兼容或未安装
        if [ "$INSTALL_STRATEGY" = "manual" ]; then
            echo ""
            echo "📖 请参考以下资源进行手动安装："
            echo "   - 项目README.md文件"
            echo "   - https://github.com/google/google-java-format"
            echo ""
            echo "建议的解决方案："
            echo "1. 升级到Java 24并安装最新版Google Java Format"
            echo "2. 降级到Java 8并使用兼容版本"
            echo "3. 查看README.md中的多版本管理方案"
        else
            echo ""
            safe_read "未检测到Java，是否查看安装指南? (y/n): " "y"
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo ""
                echo "请先安装Java，推荐以下版本："
                echo "- Java 8: 使用兼容版本Google Java Format"
                echo "- Java 24: 使用最新版本Google Java Format"
                echo ""
                echo "安装Java后，重新运行此脚本"
            fi
        fi
    fi
    
    echo ""
    echo "🎉 脚本执行完成！"
    echo ""
    if [ $JAVA_CHECK_RESULT -eq 0 ] && [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "接下来的步骤："
        echo "1. 重启终端或运行 'source ~/.zshrc' (或对应的shell配置文件)"
        echo "2. 在VS Code中安装Google Java Format Plugin扩展"
        echo "3. 在VS Code设置中配置Java格式化工具"
        echo ""
        echo "VS Code配置示例："
        echo '{'
        echo '  "[java]": {'
        echo '    "editor.defaultFormatter": "google-java-format.google-java-format-plugin"'
        echo '  },'
        if [ "$INSTALL_STRATEGY" = "java8" ] || [ "$INSTALL_STRATEGY" = "java24" ]; then
            echo '  "google-java-format.executable-path": "'$HOME'/.local/bin/google-java-format"'
        fi
        echo '}'
    else
        echo "如需帮助，请查看项目README.md文件"
    fi
}

# 运行主流程
main
