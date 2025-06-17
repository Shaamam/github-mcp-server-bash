#!/bin/bash
# GitHub API implementation

# Override configuration paths BEFORE sourcing the core
MCP_CONFIG_FILE="$(dirname "${BASH_SOURCE[0]}")/assets/githubserver_config.json"
MCP_TOOLS_LIST_FILE="$(dirname "${BASH_SOURCE[0]}")/assets/githubserver_tools.json"
MCP_LOG_FILE="$(dirname "${BASH_SOURCE[0]}")/logs/githubserver.log"

# Source the core MCP server implementation
source "$(dirname "${BASH_SOURCE[0]}")/mcpserver_core.sh"

# Access environment variables
GITHUB_TOKEN="${GITHUB_API_TOKEN:-}"
DEFAULT_USERNAME="${GITHUB_USERNAME:-}"

# Tool: Get repo count for a GitHub user
tool_get_repo_count() {
  local args="$1"
  local username=$(echo "$args" | jq -r '.username // empty')

  # Fallback to env variable
  if [[ -z "$username" ]]; then
    username="$DEFAULT_USERNAME"
  fi

  if [[ -z "$username" ]]; then
    echo "Missing required parameter: username"
    return 1
  fi

  local result=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/users/$username")

  local repo_count=$(echo "$result" | jq '.public_repos // 0')

  echo "{\"username\": \"$username\", \"repo_count\": $repo_count}"
  return 0
}

# Tool: Get commit count across all public repos
tool_get_commit_count() {
  local args="$1"
  local username=$(echo "$args" | jq -r '.username // empty')

  if [[ -z "$username" ]]; then
    username="$DEFAULT_USERNAME"
  fi


  if [[ -z "$username" ]]; then
    echo "Missing required parameter: username"
    return 1
  fi

  local repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/users/$username/repos?per_page=100")

  if [[ -z "$repos" || "$repos" == "[]" ]]; then
    echo "{\"username\": \"$username\", \"commit_count\": 0}"
    return 0
  fi

  local total_commits=0

  for repo in $(echo "$repos" | jq -r '.[].name'); do
    local commits=$(curl -s -I -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/$username/$repo/commits?per_page=1" | \
      grep -i '^link:' | sed -n 's/.*&page=\([0-9]*\)>; rel="last".*/\1/p')

    total_commits=$((total_commits + ${commits:-1}))
  done

  echo "{\"username\": \"$username\", \"commit_count\": $total_commits}"
  return 0
}

# Tool: Get GitHub profile information
tool_get_profile_info() {
  local args="$1"
  local username=$(echo "$args" | jq -r '.username // empty')

  if [[ -z "$username" ]]; then
    username="$DEFAULT_USERNAME"
  fi

  if [[ -z "$username" ]]; then
    echo "Missing required parameter: username"
    return 1
  fi

  local profile=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/users/$username")

  if [[ -z "$profile" ]]; then
    echo "Failed to fetch profile info"
    return 1
  fi

  echo "$profile"
  return 0
}

# Start the MCP server
run_mcp_server "$@"
