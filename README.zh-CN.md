# AI Agent Engine for Codex 中文说明

AI Agent Engine for Codex 是一个全新的 Codex 原生工程操作系统。它以 skill-first 插件和本地安全脚本为核心，把产品意图转成需求澄清、可执行计划、验证驱动执行、审查契约、恢复建议和交付证据。

本项目定位为 Codex 上的创新项目，不再描述为任何现有运行时的转换版本。尚未实现的内容统一归类为待优化能力或待开发能力。

## 这个项目解决什么问题

Codex 可以完成大量工程任务，但复杂工作常常缺少稳定的流程骨架：什么时候澄清需求、什么时候写计划、什么时候进入执行、如何审查、失败后如何恢复、完成时拿什么证据交付。

本项目用一组可组合 skills 和脚本化检查，把这些工程动作固化为可复用流程，让 Codex 在需求、计划、执行、审查、重构、恢复和验证之间形成清晰闭环。

## 已包含的技能

| 技能 | 触发示例 | 用途 |
| --- | --- | --- |
| `ae:lfg` | `/ae-lfg` | 从需求到验证交付的主流程 |
| `ae:brainstorm` | `/ae-brainstorm` | 澄清需求、范围、约束和成功标准 |
| `ae:plan` | `/ae-plan` | 生成可执行、决策完整的实施计划 |
| `ae:work` | `/ae-work` | 按计划执行并收集验证证据 |
| `ae:review` | `/ae-review` | 审查代码、文档或当前变更 |
| `ae:refactor` | `/ae-refactor` | 行为保持型重构和技术债治理 |
| `ae:task-loop` | `/ae-task-loop` | 循环修复直到验证通过或遇到真实阻塞 |
| `ae:help` | `/ae-help` | 查看当前技能包帮助 |
| `ae:gate` | `/ae-gate` | 运行脚本化阶段门禁和交付证明 |
| `ae:recovery` | `/ae-recovery` | 从已有产物推断下一步 AE 技能 |
| `ae:review-contract` | `/ae-review-contract` | 生成审查角色和门控规则 |
| `ae:swagger-parser` | `/ae-swagger-parser` | 解析本地 Swagger/OpenAPI JSON |
| `ae:prompt-optimize` | `/ae-prompt-optimize` | 优化提示词但不创建新会话 |
| `ae:document-review` | `/ae-document-review` | 文档专项审查 |
| `ae:save-rules` | `/ae-save-rules` | 保存长期规则到 `docs/ae/rules/` |
| `ae:handoff` | `/ae-handoff` | 生成跨会话交接文档 |
| `ae:frontend-design` | `/ae-frontend-design` | Codex 原生前端设计流程 |
| `ae:test-browser` | `/ae-test-browser` | 浏览器验收流程 |
| `ae:sql` | `/ae-sql` | 安全 SQL 意图分类 |
| `ae:figma-assets` | `/ae-figma-assets` | 已授权本地 Figma 资产整理 |
| `ae:update` | `/ae-update` | 更新并验证插件仓库 |

说明：`/ae-*` 当前是触发文本；原生命令注册属于待开发能力。

## 目录结构

```text
ai-agent-engine-codex/
  .codex-plugin/
    plugin.json
  assets/
    .gitkeep
  scripts/
    ae-gate.ps1
    ae-recovery.ps1
    ae-review-contract.ps1
    test-core-tools.ps1
    test-roadmap-surface.ps1
    validate-plugin.ps1
  skills/
    ae-brainstorm/
    ae-help/
    ae-lfg/
    ae-plan/
    ae-gate/
    ae-recovery/
    ae-review-contract/
    ae-refactor/
    ae-review/
    ae-task-loop/
    ae-work/
  README.md
  README.zh-CN.md
```

## 自动化校验

在仓库根目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-plugin.ps1
```

校验脚本会检查：

- 插件 manifest 是否可解析。
- 插件名、skills 路径和能力声明是否符合当前项目约定。
- 核心技能文件是否完整存在。
- 每个技能是否包含正确的 `name`、`description`、`ae:*` 和 `/ae-*` 触发别名。
- 代表性触发用例是否能覆盖到对应 skill。
- 是否残留旧定位、旧平台或转换叙事。
- README 是否说明当前能力、待优化能力和待开发能力。

核心闭环脚本可单独验证：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-core-tools.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-roadmap-surface.ps1
```

## 本机登记与回滚

本项目不会自动修改全局 Codex marketplace 配置。需要本机安装测试时，优先使用可回滚脚本，而不是手工编辑 Codex 状态：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\register-local-marketplace.ps1
```

该脚本会在 `%USERPROFILE%\.codex\local-marketplaces\ae-codex` 下生成本地 marketplace，将干净插件快照复制到 marketplace 的 `plugins/` 目录，并把相同版本同步到 `%USERPROFILE%\.codex\plugins\cache\ae-local\ai-agent-engine-codex\`。

需要撤销本机登记时运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\unregister-local-marketplace.ps1
```

## 当前创新能力

- `ae-gate.ps1`：返回 pass/block 门禁结果，final 阶段可写入 `docs/ae/gates/` 证明文件。
- `ae-recovery.ps1`：扫描 `docs/ae/brainstorms/`、`docs/ae/plans/` 和 `docs/ae/gates/`，推荐下一步 skill。
- `ae-review-contract.ps1`：根据审查类型和风险开关返回审查角色和门控规则。
- `ae-swagger-parser.ps1`：解析本地 Swagger/OpenAPI JSON，并用 golden fixtures 固定输出。
- `register-local-marketplace.ps1` / `unregister-local-marketplace.ps1`：提供本机 marketplace 登记、插件快照和 cache 清理。
- SQL、Figma、browser 和 frontend 能力采用安全边界，凭证化执行先进入待开发队列。

## 待优化能力

- 动态 help 根据用户意图排序，优先展示最相关的 AE skill。
- recovery 根据 git 状态、handoff、proof 文件和失败检查做更精确的下一步建议。
- review contract 增加严重级别校准、审查角色选择理由和剩余风险提示。
- CI 增加 Windows PowerShell、PowerShell Core 和 hosted runner 的一致性检查。

## 待开发能力

- 安全的 `/ae-*` 原生命令注册。
- 带凭证边界、审计日志和可回滚写入的 Figma 导出。
- 只读 SQL 巡检画像，以及经过 allowlist 确认后的受控执行。
- 浏览器验收自动化：截图、console 捕获、取消处理和产物摘要。
- 面向 Codex 会话的项目记忆层，用于长期规则、handoff 和交付证据复用。
