-- MCP servers are NOT configured in this file. mcp-hub reads them from JSON:
--   global:    ~/.config/mcphub/servers.json   (outside this repo, so secrets never land in git)
--   workspace: .mcphub/servers.json, .vscode/mcp.json or .cursor/mcp.json in a project root
--              (merged on top of the global file, served by a per-project hub on ports 40000-41000)
-- Format: { "mcpServers": { "<name>": { "command", "args", "env" } | { "url", "headers" } },
--           "nativeMCPServers": { "neovim": { "disabled": true } } }
-- Secrets: "${env:VAR}" or "${cmd: security find-generic-password -s <name> -w}" (macOS keychain).
-- Edit the file or use :MCPHub (it hot-reloads); see README.md "MCP servers (MCPHub)".
-- Note: avante's claude-code (ACP) provider doesn't see these; Claude Code uses its own `claude mcp` config.
return {
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
		},
		-- start the hub after startup so it's ready before the first avante request
		-- (avante's system_prompt/custom_tools read the running hub's state)
		event = "VeryLazy",
		cmd = "MCPHub",
		build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
		-- uncomment this if you don't want mcp-hub to be available globally or can't use -g
		-- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
		config = function()
			require("mcphub").setup({
				extensions = {
					avante = {
						make_slash_commands = true, -- make /slash commands from MCP server prompts
					},
				},
			})
		end,
	},
}
