---
name: ae:swagger-parser
description: "Parse Swagger/OpenAPI JSON in Codex. Trigger on ae:swagger-parser, /ae-swagger-parser, Swagger parser, OpenAPI summary, API interface summary, or endpoint detail."
---

# AE Swagger Parser

Use this skill to summarize local Swagger 2.0 or OpenAPI 3.x JSON files.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-swagger-parser.ps1 -Source <json> -Mode overview
```

For endpoint detail, pass `-Mode detail` plus filters such as `-Method GET -Path /pets/{id}`.

The script is local-only in this version. Remote URL fetching, dependency policies, and advanced `$ref` resolution are intentionally deferred.
