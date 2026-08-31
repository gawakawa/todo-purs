# Developer Guide

## Commands

`flake.nix` is split into two independent flakes — root, `frontend/` — each with its own
`flake.lock` and `.envrc`. Run each flake's `nix` commands from its own directory.

### Root (formatting, lint)

- `nix fmt` - Format `*.nix` and `*.json`/`*.md`/`*.yaml` repo-wide
- `nix flake check` - Run format/lint checks (statix, deadnix, actionlint, zizmor, workflow-timeout)

### Frontend

- `cd frontend && nix fmt` - Format `*.purs`
- `cd frontend && nix flake check` - Run checks (format, PureScript test)
- `cd frontend && nix build . --out-link output` - Compile `src/` into per-module ES modules
- `cd frontend && purs-nix compile` - Generate `output/` for editor/LSP use
- `cd frontend && npm install` - Install npm dependencies
- `cd frontend && npm run serve` - Start the dev server at http://localhost:5173
- `cd frontend && npm run build` - Build for production into `dist/`
  (requires `purs-nix compile` first)
