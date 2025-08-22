# 变更日志

本文档记录了项目的所有重要变更。

## [1.0.0] - 2025-01-19

### 新增
- 初始版本发布
- 支持Google Style和AOSP格式化风格
- 直接调用系统安装的google-java-format工具
- 支持整个文档和选中范围的格式化
- 一键切换格式化风格功能
- 自定义可执行文件路径配置
- 额外命令行参数支持
- Apache 2.0开源许可证
- 自动安装脚本解决Java版本兼容性问题
- 完整的Java版本管理解决方案

### 特性
- 轻量级实现，无需下载额外文件
- 简洁的配置选项
- 完整的错误处理和用户提示
- 多种安装和调试方式
- Java版本兼容性问题完整解决方案

### 技术细节
- 基于VS Code DocumentFormattingEditProvider API
- 支持DocumentRangeFormattingEditProvider
- TypeScript实现
- 遵循AOSP代码格式规范
- Apache 2.0许可证合规

### 文档和工具
- 详细的README文档，包含Java版本问题解决方案
- 自动安装脚本 (install-google-java-format.sh)
- 使用指南 (USAGE.md)
- Apache 2.0许可证文件 (LICENSE.md)
- 调试和开发指南

## 格式说明

- `新增` 为新功能
- `变更` 为现有功能的变更  
- `废弃` 为即将移除的功能
- `移除` 为已移除的功能
- `修复` 为问题修复
- `安全` 为安全相关的修复
