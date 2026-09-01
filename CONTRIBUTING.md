# Developer Guide

## Commands

`flake.nix` is a single flake at the repo root. `frontend/` and `backend/` build as separate
packages (`.#frontend` / `.#backend`) from that one flake; there is no `packages.default`.

### Root (formatting, lint, both projects' tests)

- `nix fmt` - Format `*.nix`, `*.purs`, and `*.json`/`*.md`/`*.yaml` repo-wide
- `nix flake check` - Run format/lint checks (statix, deadnix, actionlint, zizmor,
  workflow-timeout) and both projects' PureScript tests
- `nix build .#frontend --out-link frontend/output` - Compile `frontend/src/` into per-module ES modules
- `nix build .#backend --out-link backend/output` - Compile `backend/src/` into per-module ES modules

### Frontend

- `cd frontend && purs-nix compile` - Generate `output/` for editor/LSP use
  (direnv loads the `frontend` devShell here)
- `cd frontend && npm install` - Install npm dependencies
- `cd frontend && npm run serve` - Start the dev server at http://localhost:5173
  (`/api/*` proxies to `http://localhost:8080`, see `vite.config.js`)
- `cd frontend && npm run build` - Build for production into `dist/`
  (requires `purs-nix compile` first)

### Backend

- `cd backend && purs-nix compile` - Generate `output/` for editor/LSP use
  (direnv loads the `backend` devShell here)
- `cd backend && node --input-type=module -e 'import("./output/Main/index.js").then(m => m.main())'` - Run the dev server
  (requires `nix build .#backend --out-link backend/output` or `purs-nix compile` first)
