# github-mcp-server-bash
Github MCP Server for Bash

This project provides a **GitHub integration server** compatible with the **MCP (Modular Command Protocol)** specification. It allows clients to retrieve GitHub user statistics and profile information via standard tools.

---

### 🛠️ Features

* 🔍 `tool_get_repo_count` – Returns public repo count
* 📊 `tool_get_commit_count` – Returns total commit count across public repos
* 👤 `tool_get_profile_info` – Returns user profile info (bio, followers, etc.)

All tools use the `GITHUB_USERNAME` and `GITHUB_API_TOKEN` environment variables.

---

### 📁 Project Structure

```
.
├── githubserver.sh                # Main server script
├── assets/
│   ├── githubserver_config.json  # MCP server config
│   └── githubserver_tools.json   # Tool definitions
├── logs/
│   └── githubserver.log          # Log output
└── mcpserver_core.sh             # Core MCP logic (sourced by server)
```

---

### ⚙️ MCP Configuration (VS Code)

Here's a sample `mcp.json` (used by the VS Code MCP extension or environment):

```json
{
  "mcp": {
    "servers": {
      "my-github-server": {
        "type": "stdio",
        "command": "/absolute/path/to/githubserver.sh",
        "args": [],
        "env": {
          "GITHUB_API_TOKEN": "your_github_pat",
          "GITHUB_USERNAME": "Shaamam"
        }
      }
    }
  }
}
```

> 🛡️ **Note**: Ensure your GitHub token (`GITHUB_API_TOKEN`) has `repo` access for private repositories if needed, though only public repos are used by default.

---

### 🚀 Running the Server

Make sure all scripts are executable:

```bash
chmod +x githubserver.sh
```

You can now launch the server via the MCP toolchain or your VS Code extension.

---

### 🧪 Available Tools

#### 🔹 `tool_get_repo_count`

Returns the number of public repositories for the user defined in `GITHUB_USERNAME`.

#### 🔹 `tool_get_commit_count`

Returns the **total commit count** across all public repos.

#### 🔹 `tool_get_profile_info`

Returns the GitHub profile information including name, bio, followers, etc.

---

### ❗ Requirements

* Bash
* `jq`
* `curl`
* A valid GitHub personal access token
