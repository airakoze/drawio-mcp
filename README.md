# drawio-mcp

Self-contained draw.io MCP stack for agents that need inline diagram previews, local editor URLs, and `.drawio` file output. It runs locally by default, but the MCP server can also be deployed when you want a shared or hosted endpoint.

## What It Runs

- `drawio`: published `jgraph/drawio` editor on `http://localhost:8080`
- `image-export`: published `jgraph/export-server` for local image/PDF export support
- `mcp`: combined MCP server on `http://127.0.0.1:3001/mcp`

The MCP server inlines vendored draw.io viewer assets from this repository, so diagram previews do not fetch remote viewer code at runtime.

## Requirements

- Docker with Docker Compose for the full local stack
- Node.js 18+ for running the MCP server directly

## Local Quick Start

```bash
make start
```

Open draw.io:

```text
http://localhost:8080/?offline=1&https=0
```

HTTP MCP endpoint:

```text
http://127.0.0.1:3001/mcp
```

Saved diagrams are written to the Docker volume:

```text
drawio-mcp_diagrams
```

Useful Make targets:

```bash
make up-detached  # start the full stack in the background
make drawio       # start only draw.io and image export
make mcp          # run the MCP server directly with Node.js
make stdio        # run the MCP server over stdio
make logs         # follow Docker logs for the MCP service
make down         # stop the Docker stack
make check        # run syntax checks
```

## Run MCP Locally Without Docker

Start the draw.io editor service:

```bash
make drawio
```

In another terminal, install dependencies and start the MCP server:

```bash
make install
make mcp
```

For stdio clients:

```bash
make stdio
```

Example MCP config for stdio agents:

```json
{
  "mcpServers": {
    "drawio": {
      "command": "node",
      "args": [
        "/absolute/path/to/drawio-mcp/src/index.js",
        "--stdio"
      ],
      "env": {
        "DRAWIO_BASE_URL": "http://localhost:8080/",
        "DRAWIO_OUTPUT_DIR": "/absolute/path/to/drawio-mcp/diagrams"
      }
    }
  }
}
```

For a Docker-based stdio harness, prefer a Docker-managed named volume rather than an absolute host path:

```json
{
  "mcpServers": {
    "drawio": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "drawio-mcp_diagrams:/data/diagrams",
        "-e",
        "DRAWIO_BASE_URL=http://localhost:8080/",
        "-e",
        "DRAWIO_OUTPUT_DIR=/data/diagrams",
        "-e",
        "VIEWER_PATH=/app/viewer",
        "-e",
        "OPEN_BROWSER=0",
        "drawio-mcp-mcp",
        "node",
        "src/index.js",
        "--stdio"
      ]
    }
  }
}
```

If you want generated `.drawio` files to appear directly in a local folder during development, replace the named volume argument with an absolute bind mount:

```json
"-v",
"/absolute/path/to/diagrams:/data/diagrams"
```

## Tools

- `create_diagram`: inline MCP App preview from draw.io XML or Mermaid.
- `search_shapes`: local shape index search for exact draw.io style strings.
- `open_drawio_xml`: returns a local editor URL for XML.
- `open_drawio_csv`: returns a local editor URL for draw.io CSV import data.
- `open_drawio_mermaid`: returns a local editor URL for Mermaid.
- `save_drawio_xml`: writes native XML to a `.drawio` file. Mermaid and CSV are preview/open-only in v1.

## Configuration

| Variable | Default | Purpose |
|---|---:|---|
| `DRAWIO_BASE_URL` | `http://localhost:8080/` | Base editor URL used in generated `#create=` links |
| `DRAWIO_OUTPUT_DIR` | `/data/diagrams` in Docker, `./diagrams` locally | Directory for `save_drawio_xml` |
| `VIEWER_PATH` | `./viewer/viewer-static.min.js` | Local `viewer-static.min.js` file or draw.io webapp `js` directory |
| `PORT` | unset | Platform-provided HTTP port; used when `MCP_PORT` is not set |
| `MCP_PORT` | `$PORT`, then `3001` | HTTP MCP port |
| `MCP_LISTEN` | `127.0.0.1` | HTTP bind address; Docker uses `0.0.0.0` internally with host localhost port binding |
| `ALLOWED_HOSTS` | automatic for localhost | Comma-separated allowed HTTP hostnames when binding outside localhost |
| `DOMAIN` | unset | Public widget domain for hosted MCP app rendering |
| `OPEN_BROWSER` | stdio: on, HTTP: off | Whether open tools should launch the system browser |

## Deployment Options

The default setup is intentionally local. To host it, deploy the MCP service anywhere that can run Node.js or the included Dockerfile, and point `DRAWIO_BASE_URL` at a draw.io editor that your users can reach.

Common options:

- Railway or Render: deploy this repository from the Dockerfile. Set `MCP_LISTEN=0.0.0.0`, leave `MCP_PORT` unset if the platform provides `PORT`, set `DRAWIO_BASE_URL` to your hosted draw.io URL, and set `ALLOWED_HOSTS` to the generated service hostname.
- Fly.io, DigitalOcean, or a VM: run the Compose stack behind HTTPS. Expose the MCP service and draw.io editor through your reverse proxy, then set `DRAWIO_BASE_URL` to the public draw.io origin.
- MCP-only deployment: run just this Node service and use an existing reachable draw.io instance for `DRAWIO_BASE_URL`. Keep `VIEWER_PATH` pointed at the vendored viewer or `/app/viewer` in Docker.

For any remote deployment, use HTTPS at the edge and restrict `ALLOWED_HOSTS` to the public hostname of the MCP service.

## GitHub

This repository is ready to push as a standalone project. Generated diagrams, local dependencies, logs, and environment files are ignored by Git.

```bash
npm run check
git add .
git commit -m "Initial drawio MCP project"
git branch -M main
git remote add origin git@github.com:YOUR_ORG/drawio-mcp.git
git push -u origin main
```

The included GitHub Actions workflow installs dependencies with `npm ci` and runs the syntax check on every push and pull request.
