# AI Agent Engine for Codex 中文说明

这是 AI Agent Engine 的 Codex 原生迁移版本。它采用“技能包优先”的方式，把 AE 的核心工程工作流迁移为 Codex 可发现、可触发、可执行的 skills，并补充脚本化门禁、恢复和审查契约能力。

V1 的目标不是完整复刻 opencode 插件运行时，而是先提供稳定、可维护、可验证的 Codex 工作流能力。

## 这个仓库解决什么问题

原始 `ai-agent-engine` 面向 opencode，依赖 opencode 的插件服务器、自定义工具、TUI、命令注册和运行时配置。Codex 插件的可移植形态更适合通过 `.codex-plugin/plugin.json` 声明插件，并通过 `skills/` 提供可组合工作流。

因此，本仓库将 AE 的核心工程方法迁移为 Codex 技能包，让 Codex 可以围绕需求澄清、计划、执行、审查、重构和验证形成稳定流程。

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

说明：`/ae-*` 在 V1 中是触发文本，不是 Codex 原生命令。

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
- 插件名、skills 路径和能力声明是否符合 V1 约定。
- 8 个核心技能是否都存在。
- 每个技能是否包含正确的 `name`、`description`、`ae:*` 和 `/ae-*` 触发别名。
- 5 个代表性触发用例是否能覆盖到对应 skill。
- 是否残留 opencode-only 的强依赖。
- README 是否说明激活边界和后续延期能力。

核心闭环脚本可单独验证：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-core-tools.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-migration-surface.ps1
```

## 已迁移的核心工具替代能力

- `ae-gate.ps1`：返回 pass/block 门禁结果，final 阶段可写入 `docs/ae/gates/` 证明文件。
- `ae-recovery.ps1`：扫描 `docs/ae/brainstorms/`、`docs/ae/plans/` 和 `docs/ae/gates/`，推荐下一步 skill。
- `ae-review-contract.ps1`：根据审查类型和风险开关返回审查角色和门控规则。

## 0.3 已迁移能力

- 本机 marketplace 登记和回滚脚本。
- Swagger/OpenAPI 本地 JSON 解析和 golden fixtures 测试。
- 动态 help catalog。
- prompt optimize、document review、save-rules、handoff。
- 26 个 reviewer reference 和 reviewer catalog。
- frontend/browser/SQL/Figma/update 的 Codex 安全边界。
- GitHub Actions 验证工作流。

## V3 边界

本版本暂不迁移以下能力：

- opencode TypeScript plugin server
- opencode TUI
- 原生 `/ae-*` 命令注册系统
- 真实 Figma API 导出
- 真实 SQL 执行
- 自动浏览器 E2E
- Codex 运行时热加载验证

这些能力更适合作为 V2，通过 MCP、脚本或 Codex 插件扩展机制重新设计。

## 推荐下一步

1. 将该目录登记到本机 Codex marketplace。
2. 新开 Codex 会话测试 `/ae-help`、`/ae-plan`、`/ae-review`、`/ae-lfg`。
3. 根据真实触发效果，决定优先迁移动态帮助、门禁验证，还是 Swagger/Figma/SQL 等专项能力。
    ae-swagger-parser.ps1
    ae-prompt-optimize.ps1
    ae-help-catalog.ps1
    ae-save-rules.ps1
    ae-handoff.ps1
    ae-reviewer-catalog.ps1
    ae-sql.ps1
    ae-figma-assets.ps1
    register-local-marketplace.ps1
    unregister-local-marketplace.ps1
    test-migration-surface.ps1
