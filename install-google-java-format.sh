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

# 检查操作系统
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

echo "检测到操作系统: $OS"

# 检查当前Java版本
check_java_version() {
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1-2)
        echo "当前Java版本: $JAVA_VERSION"
        
        # 检查是否为Java 11+
        MAJOR_VERSION=$(echo $JAVA_VERSION | cut -d'.' -f1)
        if [ "$MAJOR_VERSION" -ge 11 ] 2>/dev/null; then
            echo "✅ Java版本满足要求 (>= 11)"
            return 0
        else
            echo "⚠️  Java版本过低，需要Java 11或更高版本"
            return 1
        fi
    else
        echo "❌ 未检测到Java"
        return 1
    fi
}

# 安装Java 11
install_java11() {
    echo ""
    echo "正在安装Java 11..."
    
    if [ "$OS" = "macos" ]; then
        if command -v brew &> /dev/null; then
            echo "使用Homebrew安装OpenJDK 11..."
            brew install openjdk@11
            
            # 设置环境变量
            echo "配置环境变量..."
            SHELL_RC=""
            if [ -n "$ZSH_VERSION" ]; then
                SHELL_RC="$HOME/.zshrc"
            elif [ -n "$BASH_VERSION" ]; then
                SHELL_RC="$HOME/.bash_profile"
            else
                SHELL_RC="$HOME/.profile"
            fi
            
            echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >> "$SHELL_RC"
            echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> "$SHELL_RC"
            
            echo "✅ Java 11安装完成，请运行以下命令重新加载配置："
            echo "source $SHELL_RC"
        else
            echo "❌ 请先安装Homebrew: https://brew.sh"
            exit 1
        fi
    elif [ "$OS" = "linux" ]; then
        echo "安装OpenJDK 11..."
        if command -v apt-get &> /dev/null; then
            sudo apt update
            sudo apt install -y openjdk-11-jdk
        elif command -v yum &> /dev/null; then
            sudo yum install -y java-11-openjdk-devel
        else
            echo "❌ 不支持的包管理器，请手动安装Java 11"
            exit 1
        fi
        echo "✅ Java 11安装完成"
    fi
}

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
            install_manual()
        fi
    fi
}

# 手动安装（下载jar文件）
install_manual() {
    echo "手动安装Google Java Format..."
    
    # 创建安装目录
    INSTALL_DIR="$HOME/tools/google-java-format"
    mkdir -p "$INSTALL_DIR"
    
    # 下载最新版本
    echo "下载Google Java Format..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/google/google-java-format/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "⚠️  无法获取最新版本，使用默认版本 1.19.2"
        LATEST_VERSION="1.19.2"
    fi
    
    JAR_FILE="google-java-format-${LATEST_VERSION}-all-deps.jar"
    DOWNLOAD_URL="https://github.com/google/google-java-format/releases/download/v${LATEST_VERSION}/${JAR_FILE}"
    
    echo "下载 $JAR_FILE ..."
    curl -L -o "$INSTALL_DIR/$JAR_FILE" "$DOWNLOAD_URL"
    
    # 创建启动脚本
    cat > "$INSTALL_DIR/google-java-format" << EOF
#!/bin/bash
java -jar "$INSTALL_DIR/$JAR_FILE" "\$@"
EOF
    
    chmod +x "$INSTALL_DIR/google-java-format"
    
    # 添加到PATH
    SHELL_RC=""
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bash_profile"
    else
        SHELL_RC="$HOME/.profile"
    fi
    
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
    
    echo "✅ Google Java Format手动安装完成"
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

# 主流程
main() {
    echo ""
    
    # 检查Java版本
    if ! check_java_version; then
        echo ""
        read -p "是否安装Java 11? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_java11
        else
            echo "跳过Java安装，将尝试手动安装Google Java Format"
        fi
    fi
    
    echo ""
    read -p "是否安装Google Java Format? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null && [ "$OS" = "macos" ]; then
            install_google_java_format
        elif command -v apt-get &> /dev/null && [ "$OS" = "linux" ]; then
            install_google_java_format  
        else
            echo "使用手动安装方式..."
            install_manual
        fi
        
        verify_installation
    fi
    
    echo ""
    echo "🎉 安装完成！"
    echo ""
    echo "接下来的步骤："
    echo "1. 重启终端或运行 'source ~/.zshrc' (或对应的shell配置文件)"
    echo "2. 在VS Code中安装Google Java Format Plugin扩展"
    echo "3. 在设置中配置Java格式化工具"
    echo ""
    echo "VS Code配置示例："
    echo '{'
    echo '  "[java]": {'
    echo '    "editor.defaultFormatter": "google-java-format.google-java-format-plugin"'
    echo '  }'
    echo '}'
}

# 运行主流程
main
