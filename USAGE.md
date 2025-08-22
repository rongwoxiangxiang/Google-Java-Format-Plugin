# 使用指南

## 快速开始

1. **安装Google Java Format工具**
   ```bash
   # macOS
   brew install google-java-format
   
   # 或手动下载jar文件
   wget https://github.com/google/google-java-format/releases/latest/download/google-java-format-X.X.X-all-deps.jar
   ```

2. **配置VS Code**
   ```json
   {
     "[java]": {
       "editor.defaultFormatter": "google-java-format.google-java-format-plugin"
     }
   }
   ```

3. **开始使用**
   - 打开Java文件
   - 按 `Shift + Alt + F` 格式化

## 格式化风格切换

### 方法1：右键菜单
1. 在Java文件中右键
2. 选择"切换格式化风格（Google/AOSP）"

### 方法2：命令面板
1. 按 `Ctrl+Shift+P`
2. 输入"切换格式化风格"
3. 回车执行

### 方法3：设置面板
1. 打开设置 `Ctrl+,`
2. 搜索"google-java-format.style"
3. 选择"google"或"aosp"

## 自定义配置

### 指定工具路径
如果google-java-format不在PATH中：
```json
{
  "google-java-format.executable-path": "/path/to/google-java-format"
}
```

### 添加额外参数
```json
{
  "google-java-format.extra-args": "--skip-sorting-imports --dry-run"
}
```

## 故障排除

### 检查工具安装
```bash
which google-java-format
google-java-format --version
```

### 测试格式化
```bash
echo "class Test{}" | google-java-format -
```

### 常见错误

**错误**: "无法启动Google Java Format"
**原因**: 工具未安装或路径错误
**解决**: 安装工具或检查配置

**错误**: 格式化无效果
**原因**: Java代码有语法错误
**解决**: 修复语法错误后重试

## 键盘快捷键

| 操作 | Windows/Linux | macOS |
|------|---------------|-------|
| 格式化文档 | `Shift + Alt + F` | `Shift + Option + F` |
| 格式化选择 | `Shift + Alt + F` | `Shift + Option + F` |
| 命令面板 | `Ctrl + Shift + P` | `Cmd + Shift + P` |

## 支持的文件类型

- `.java` - Java源文件
- 其他Java相关文件类型（如果VS Code识别为Java语言）

## 性能提示

- 大文件格式化可能需要几秒钟
- 格式化会保留文件原有编码
- 支持撤销（Ctrl+Z）恢复格式化前状态
