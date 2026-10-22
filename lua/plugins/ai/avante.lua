-- Extends EcoVimAI from config/EcoVim.lua (kept out of the upstream file)
---@class EcoVimAI
---@field model? string Copilot model used by avante (default: "claude-opus-5.5")
---@field claudeModel? string Claude Code model for the claude-code ACP provider, Anthropic ID or alias (default: Claude Code's own setting)
---@field lmstudioModel? string LM Studio model id (default: "qwen/qwen3.8-27b")

return {
	{
		"avante-corp/avante.nvim",
		enabled = EcoVim.plugins.ai.avante.enabled,
		lazy = false,
		version = false,
		opts = {
			-- Switch at runtime with :AvanteSwitchProvider (copilot | claude-code | lmstudio)
			provider = "copilot",
			mode = "agentic", -- The default mode for interaction. "agentic" uses tools to automatically generate code, "legacy" uses the old planning method to generate code.
			auto_suggestions_provider = "copilot",
			behaviour = {
				auto_apply_diff_after_generation = false,
				auto_focus_sidebar = true,
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_suggestions = false,
				enable_cursor_planning_mode = true,
				jump_result_buffer_on_finish = false,
				minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
				support_paste_from_clipboard = true,
			},
			hints = { enabled = true },
			providers = {
				copilot = {
					-- override via EcoVim.plugins.ai.avante.model in user.lua
					model = EcoVim.plugins.ai.avante.model or "claude-opus-5.5",
					-- model = "grok-code-fast-1",
					disable_tools = false,
					extra_request_body = {
						-- output tokens, not context: Copilot rejects/clamps values above the model's output cap
						max_tokens = 32000,
					},
				},
				-- Local model served by LM Studio (OpenAI-compatible API)
				lmstudio = {
					__inherited_from = "openai",
					endpoint = "http://127.0.0.1:1234/v1",
					-- override via EcoVim.plugins.ai.avante.lmstudioModel in user.lua
					model = EcoVim.plugins.ai.avante.lmstudioModel or "qwen/qwen3.8-27b",
					api_key_name = "", -- LM Studio doesn't need a key
					timeout = 120000, -- local generation is slow
					context_window = 200000, -- keep below LM Studio's loaded context length
					use_response_api = false,
					extra_request_body = {
						temperature = 0.6,
						max_completion_tokens = 16384,
					},
				},
			},
			-- Claude Code over ACP: runs the official `claude` CLI with its claude.ai (Pro) login.
			-- Needs `npm i -g @agentclientprotocol/claude-agent-acp` on PATH.
			acp_providers = {
				["claude-code"] = {
					command = "claude-agent-acp",
					env = {
						-- avante passes only PATH + this table; Claude Code needs HOME and USER
						-- (keychain lookup) to find its claude.ai login, otherwise prompts hang
						HOME = os.getenv("HOME"),
						USER = os.getenv("USER"),
						-- override via EcoVim.plugins.ai.avante.claudeModel in user.lua; nil keeps Claude Code's default
						ANTHROPIC_MODEL = EcoVim.plugins.ai.avante.claudeModel,
					},
				},
			},
			-- system_prompt as function ensures LLM always has latest MCP server state
			-- This is evaluated for every message, even in existing chats
			system_prompt = function()
				local ok, mcphub = pcall(require, "mcphub")
				if not ok then return "" end
				local hub = mcphub.get_hub_instance()
				return hub and hub:get_active_servers_prompt() or ""
			end,
			-- Using function prevents requiring mcphub before it's loaded
			custom_tools = function()
				local ok, ext = pcall(require, "mcphub.extensions.avante")
				if not ok then return {} end
				return { ext.mcp_tool() }
			end,
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			"zbirenbaum/copilot.lua",
			-- avante's rockspec deps, installed as plain plugins since lazy's luarocks support is disabled
			"ColinKennedy/mega.cmdparse",
			"ColinKennedy/mega.logging",
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			"MeanderingProgrammer/render-markdown.nvim",
		},
	},
}
