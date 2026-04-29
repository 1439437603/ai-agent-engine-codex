---
name: ae:sql
description: "Classify and safely prepare SQL work in Codex. Trigger on ae:sql, /ae-sql, SQL query, database check, JDBC, or inspect database."
---

# AE SQL

Use this skill for database-related tasks with safe defaults.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-sql.ps1 -ConnectionString "<redacted>" -Query "SELECT 1"
```

This version does not execute database queries. It classifies SQL intent, redacts connection data, and blocks write-like statements unless explicitly authorized in a controlled environment.
