/**
 * Copyright 2025 Google Java Format Plugin Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Google Java Format Plugin for VS Code
 * 简洁的Java代码格式化工具，支持Google Style和AOSP格式
 * 
 * @author Google Java Format Plugin Team  
 * @date 2025-01-19
 */

import * as vscode from 'vscode';
import { spawn } from 'child_process';

/**
 * 简单的Google Java Format格式化提供程序
 * 直接调用系统中安装的google-java-format工具
 */
class GoogleJavaFormatProvider implements vscode.DocumentFormattingEditProvider, vscode.DocumentRangeFormattingEditProvider {
    
    /**
     * 获取配置设置
     */
    private getConfiguration(): { executablePath: string; style: string; extraArgs: string } {
        const config = vscode.workspace.getConfiguration('google-java-format');
        return {
            executablePath: config.get('executable-path', 'google-java-format'),
            style: config.get('style', 'google'),
            extraArgs: config.get('extra-args', '')
        };
    }

    /**
     * 构建命令行参数
     */
    private buildArgs(config: { style: string; extraArgs: string }): string[] {
        const args: string[] = [];
        
        // 添加格式化风格参数
        if (config.style === 'aosp') {
            args.push('--aosp');
        }
        
        // 添加额外参数
        if (config.extraArgs) {
            args.push(...config.extraArgs.split(' ').filter(arg => arg.trim()));
        }
        
        // 使用stdin模式
        args.push('-');
        
        return args;
    }

    /**
     * 执行格式化操作
     */
    private async formatCode(code: string): Promise<string> {
        const config = this.getConfiguration();
        const args = this.buildArgs(config);

        return new Promise((resolve, reject) => {
            const process = spawn(config.executablePath, args, {
                stdio: ['pipe', 'pipe', 'pipe']
            });

            let stdout = '';
            let stderr = '';

            process.stdout.on('data', (data) => {
                stdout += data.toString();
            });

            process.stderr.on('data', (data) => {
                stderr += data.toString();
            });

            process.on('close', (code) => {
                if (code === 0) {
                    resolve(stdout);
                } else {
                    reject(new Error(`Google Java Format执行失败 (退出码: ${code}): ${stderr || '未知错误'}`));
                }
            });

            process.on('error', (error) => {
                reject(new Error(`无法启动Google Java Format: ${error.message}。请确保已安装google-java-format并正确配置路径。`));
            });

            // 写入代码到stdin
            process.stdin.write(code);
            process.stdin.end();
        });
    }

    /**
     * 格式化整个文档
     */
    async provideDocumentFormattingEdits(
        document: vscode.TextDocument,
        options: vscode.FormattingOptions,
        token: vscode.CancellationToken
    ): Promise<vscode.TextEdit[]> {
        return this.formatDocument(document, token);
    }

    /**
     * 格式化文档范围
     */
    async provideDocumentRangeFormattingEdits(
        document: vscode.TextDocument,
        range: vscode.Range,
        options: vscode.FormattingOptions,
        token: vscode.CancellationToken
    ): Promise<vscode.TextEdit[]> {
        return this.formatDocument(document, token, range);
    }

    /**
     * 执行文档格式化的核心逻辑
     */
    private async formatDocument(
        document: vscode.TextDocument,
        token: vscode.CancellationToken,
        range?: vscode.Range
    ): Promise<vscode.TextEdit[]> {
        try {
            // 检查是否取消
            if (token.isCancellationRequested) {
                return [];
            }

            // 获取要格式化的代码内容
            const text = range ? document.getText(range) : document.getText();
            const formattedText = await this.formatCode(text);

            // 如果内容没有变化，返回空数组
            if (text === formattedText) {
                return [];
            }

            // 返回编辑操作
            const targetRange = range || new vscode.Range(
                document.positionAt(0),
                document.positionAt(text.length)
            );

            return [vscode.TextEdit.replace(targetRange, formattedText)];

        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`格式化失败: ${errorMessage}`);
            return [];
        }
    }
}

/**
 * 扩展激活函数
 */
export function activate(context: vscode.ExtensionContext) {
    
    // 创建格式化提供程序实例
    const provider = new GoogleJavaFormatProvider();
    
    // 注册文档格式化提供程序
    const documentFormattingDisposable = vscode.languages.registerDocumentFormattingEditProvider('java', provider);
    context.subscriptions.push(documentFormattingDisposable);
    
    // 注册范围格式化提供程序
    const rangeFormattingDisposable = vscode.languages.registerDocumentRangeFormattingEditProvider('java', provider);
    context.subscriptions.push(rangeFormattingDisposable);

    // 注册切换格式化风格命令
    const switchStyleCommand = vscode.commands.registerCommand('googleJavaFormat.switchStyle', async () => {
        const config = vscode.workspace.getConfiguration('google-java-format');
        const currentStyle = config.get('style', 'google');
        const newStyle = currentStyle === 'google' ? 'aosp' : 'google';
        
        await config.update('style', newStyle, vscode.ConfigurationTarget.Global);
        
        // 显示切换结果
        const styleDisplayNames = {
            google: 'Google Style',
            aosp: 'AOSP Style'
        };
        vscode.window.showInformationMessage(
            `格式化风格已切换为: ${styleDisplayNames[newStyle as keyof typeof styleDisplayNames]}`
        );
    });
    context.subscriptions.push(switchStyleCommand);

    // 输出激活信息
    console.log('Google Java Format Plugin已激活');
}

/**
 * 扩展停用函数
 */
export function deactivate() {
    // 清理资源（如果需要）
}
