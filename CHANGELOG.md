# Changelog

## [Unreleased]

- Initial comprehensive repo structure for CLIProxyAPI hub setup
- Docker Compose with cliproxyapi + optional cloudflared tunnel profile
- Client config templates for Claude Code, Codex, OpenCode, Zed
- Setup, health-check, backup, and sign-in scripts
- systemd unit template
- Environment variable template (.env.example)
- Makefile with convenience targets
- NOTICE.md — legal disclaimer and liability waiver
- CREDITS.md — attribution to Theo (theo4gg) and third-party projects
- GUIDE.md — full setup guide adapted from Theo's public guide
- PLAN.md — deployment checklist
- SECURITY.md — security policy and secrets handling
- CONTRIBUTING.md — repo conventions
- CHANGELOG.md — version history

## [Planned]

- Soonest-reset-first routing implementation (Theo's change #2, not in upstream)
- Docker health check improvements
- Multi-arch Docker build support
- Automated backup cron job example
