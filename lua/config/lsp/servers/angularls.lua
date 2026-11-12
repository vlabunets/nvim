-- Warn when Mason's angular-language-server major differs from the project's Angular major.
-- ngserver loads @angular/language-service from the project's node_modules; a major mismatch
-- makes it crash and restart in a loop ("Program does not contain ...ngtypecheck.ts").

local function read_version(package_json)
  local ok, content = pcall(vim.fn.readblob, package_json)
  if not ok or not content then
    return nil
  end
  local decoded_ok, json = pcall(vim.json.decode, content)
  return decoded_ok and type(json) == "table" and json.version or nil
end

local checked_roots = {}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("angularls_version_check", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "angularls" or not client.root_dir or checked_roots[client.root_dir] then
      return
    end
    checked_roots[client.root_dir] = true

    local project = read_version(client.root_dir .. "/node_modules/@angular/core/package.json")
    local server = read_version(
      vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules/@angular/language-server/package.json"
    )
    if not project or not server or project:match("^%d+") == server:match("^%d+") then
      return
    end

    -- Mason needs an exact version, so ask npm for the newest release of the project's major
    local major = project:match("^%d+")
    vim.system({ "npm", "view", "@angular/language-server@" .. major, "version", "--json" }, { text = true }, function(res)
      local ok, versions = pcall(vim.json.decode, res.stdout or "")
      local target = ok and (type(versions) == "table" and versions[#versions] or versions) or nil
      local install = type(target) == "string" and ":MasonInstall angular-language-server@" .. target
        or ":Mason and install an angular-language-server " .. major .. ".x version"

      vim.schedule(function()
        vim.notify(
          string.format(
            "angular-language-server %s doesn't match Angular %s in this project.\nRun %s and restart Neovim.",
            server,
            project,
            install
          ),
          vim.log.levels.WARN,
          { title = "angularls" }
        )
      end)
    end)
  end,
})
