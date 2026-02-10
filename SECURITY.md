# Security Policy

## ⚠️ Important: Never Commit Personal Data

MemoryBox is a **tool** for organizing your OpenClaw memory files. Your actual memory files contain personal data and should **never** be committed to any public repository.

### What's safe to commit (this repo)
- `bin/memorybox` — the CLI tool
- `scripts/` — migration and maintenance scripts
- `templates/` — blank templates with placeholder content

### What should NEVER be committed
- `MEMORY.md` — contains personal facts, preferences, API references
- `memory/*.md` — daily logs with personal activity
- `memory/domains/*.md` — detailed personal/professional information
- Any file containing API keys, tokens, passwords, or credentials
- Any file containing addresses, phone numbers, or personal identifiers

### .gitignore protection

This repo includes a `.gitignore` that blocks common personal files. If you fork this repo to customize templates, **verify your .gitignore is working** before pushing:

```bash
git status  # Check no personal files are staged
```

### Reporting a vulnerability

If you discover a security issue, please email ramsbaby@gmail.com or open a private GitHub advisory.

### License

This project contains no user data by design. All files are templates or tools.
