# Changelog

All notable changes to the n8n Automations Toolkit.

When releasing updates, bump the version in these files:
- `.claude-plugin/marketplace.json` (all plugin entries)
- `plugins/n8n/.claude-plugin/plugin.json`
- `plugins/n8n-prd-generator/.claude-plugin/plugin.json`
- `plugins/n8n-project-init/.claude-plugin/plugin.json`

After pushing, team members should run:
```
/plugin marketplace update n8n-toolkit
/plugin uninstall <changed-plugin>@n8n-toolkit
/plugin install <changed-plugin>@n8n-toolkit
```

---

## [1.2.0] - 2025-03-16

### Changed
- **n8n**: Blueprint-first build process — reads CLAUDE.md blueprint as primary build spec, added pipeline context (Step 3 of 3), error handling setup prompt after every build
- **n8n-prd-generator**: Flexible input — accepts call transcripts, workflow descriptions, or both; collaborative discovery with clarifying questions before producing blueprint
- **n8n-project-init**: Pattern-only configuration, blueprint-first flow (checks for existing blueprint before scaffolding), streamlined 3-step pipeline handoff

### Docs
- Standardized documentation, credentials references, and blueprint output format across all plugins
- Updated README with correct GitHub org references

---

## [1.1.0] - 2025-02-19

### Changed
- **n8n-project-init**: Improved credential detection from `~/.n8n.env`
- **n8n-project-init**: Better error messaging when credentials are missing

### Fixed
- Credential detection was skipping existing profiles and asking users to enter credentials manually

### Docs
- Rewrote setup.md with detailed step-by-step instructions
- Added Appendix A (GitHub Personal Access Token setup)
- Added CHANGELOG.md for version tracking

---

## [1.0.0] - 2025-02-19

### Added
- **n8n** plugin: Build, test, and deploy n8n workflows via REST API with incremental testing
- **n8n-prd-generator** plugin: Convert stakeholder call transcripts into one-page automation blueprints
- **n8n-project-init** plugin: Scaffold new projects with CLAUDE.md, .env, .gitignore
- Project templates (CLAUDE.md.template, .env.template, .gitignore)
- README.md with team reference
- docs/setup.md with onboarding guide
