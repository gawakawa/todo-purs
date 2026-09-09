# purs-nix

## Overview

A todo app with both frontend and backend written in PureScript, running on Cloudflare Workers + D1.

## Features

## Prerequisites

## Usage

https://todo-purs.1ota.workers.dev/

## Directory Structure

```
.
├── backend            # Cloudflare Workers + D1
│   ├── migrations     # D1 schema migrations
│   ├── src
│   ├── test
│   └── wrangler.jsonc # Cloudflare Workers config
├── frontend           # React
│   ├── src
│   └── test
├── nix                # flake-parts modules
└── shared             # Imported by both frontend and backend
    └── src
```
