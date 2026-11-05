# Contributing

## Structure

```
clipproxy/
├── .env.example              # Environment variable template (copy to .env)
├── .gitignore                # Ignores .env, data/, backups/, logs
├── LICENSE.md                # MIT License
├── Makefile                  # Convenience targets (up, down, health, backup, etc.)
├── NOTICE.md                 # ⚠️ Legal disclaimer — READ THIS FIRST
├── CREDITS.md                # Attribution to Theo (theo4gg) and third-party projects
├── GUIDE.md                  # Full setup guide (adapted from Theo's guide)
├── PLAN.md                   # Deployment checklist
├── README.md                 # Overview + client configs
├── SECURITY.md               # Security policy & secrets handling
├── CONTRIBUTING.md           # This file
├── CHANGELOG.md              # Version history
├── config.yaml               # Simple root-level config
├── docker-compose.yml        # Simple root-level compose
├── config/
│   └── config.yaml.example   # CLIProxyAPI v8 config template
├── docker/
│   └── docker-compose.yml    # Compose with optional cloudflared tunnel profile
├── cloudflare/
│   └── tunnel-config.yml.example
├── clients/
│   ├── claude-code/settings.json.example
│   ├── codex/config.toml.example
│   ├── opencode/.env.example
│   └── zed/settings.json.example
├── scripts/
│   ├── setup-hub.sh
│   ├── health-check.sh
│   ├── backup.sh
│   └── signin-codex.sh
└── systemd/
    └── cliproxyapi.service
```

## Making Changes

1. Copy `config/config.yaml.example` to `config/config.yaml` and adjust.
2. Copy `.env.example` to `.env` and set your secrets.
3. Test locally before deploying to the hub.
4. Update `PLAN.md` and `GUIDE.md` if deployment steps change.
5. Update `CHANGELOG.md` with your changes.

## Do Not Commit

- `.env` — real secrets
- `config/config.yaml` — real access/management keys
- `data/` — auth state
- `backups/` — auth state backups
- `*.key`, `*.pem` — private keys

## Attribution

The original setup concept and guide are by **Theo (theo4gg)**. When modifying `GUIDE.md` or `PLAN.md`, preserve Theo's original warnings, two hard rules, and credit.
