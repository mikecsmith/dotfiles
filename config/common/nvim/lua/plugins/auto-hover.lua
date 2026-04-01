-- Auto-hover on CursorHold with treesitter filtering
-- Only shows hover for symbols likely to have useful documentation:
-- function calls, method access, type references, field access on compounds.
-- Skips plain variables, loop counters, keywords, literals.
-- Toggle with <leader>uh

-- Node types that are always worth hovering (type refs, field access)
local hoverworthy_nodes = {
  type_identifier = true,
  field_identifier = true, -- Go: obj.Method
  selector_expression = true, -- Go: obj.Method
  package_identifier = true, -- Go: pkg.Symbol
  property_identifier = true, -- TS/JS: obj.prop
  member_expression = true, -- TS/JS: obj.method
  property_access_expression = true, -- TS/JS
  dot_index_expression = true, -- Lua: obj.method
  field_expression = true, -- Rust: obj.field
  attribute = true, -- Python: obj.attr
}

-- Parents that make a plain `identifier` worth hovering
local call_parents = {
  call_expression = true, -- Go, general
  function_call = true, -- Lua
  ["call"] = true, -- Rust, Python
}

-- Declaration nodes — hover is useless here (you're writing the definition)
local declaration_nodes = {
  -- Go
  type_spec = true,
  function_declaration = true,
  method_declaration = true,
  var_spec = true,
  const_spec = true,
  parameter_declaration = true,
  -- TypeScript / JavaScript
  type_alias_declaration = true,
  interface_declaration = true,
  class_declaration = true,
  variable_declarator = true,
  -- Lua
  function_declaration_statement = true,
  -- Rust
  struct_item = true,
  function_item = true,
  type_item = true,
  let_declaration = true,
  -- Python
  class_definition = true,
  function_definition = true,
}

-- Check if cursor is at a declaration site (not a reference)
local function is_at_declaration()
  local node = vim.treesitter.get_node()
  if not node then
    return false
  end
  -- Walk up parents looking for a declaration node
  local child = node
  local parent = node:parent()
  while parent do
    if declaration_nodes[parent:type()] then
      -- Only suppress if we're on the name/identifier of the declaration,
      -- not on a type reference within it (e.g. the return type)
      local name_node = parent:field("name")
      if name_node and name_node[1] and name_node[1]:id() == child:id() then
        return true
      end
      -- Go: type_spec names the type directly
      local type_node = parent:field("type")
      if parent:type() == "type_spec" and type_node and type_node[1] then
        -- We're on the name, not the type body
        if child:id() ~= type_node[1]:id() then
          return true
        end
      end
    end
    child = parent
    parent = parent:parent()
  end
  return false
end

local function is_hoverworthy()
  local node = vim.treesitter.get_node()
  if not node then
    return false
  end

  local node_type = node:type()

  if hoverworthy_nodes[node_type] then
    return not is_at_declaration()
  end

  -- Plain identifiers only if they're a function call or part of a chain
  if node_type == "identifier" then
    local parent = node:parent()
    if parent then
      local pt = parent:type()
      if call_parents[pt] or hoverworthy_nodes[pt] then
        return not is_at_declaration()
      end
    end
    return false
  end

  -- Walk up to 2 parents for compound expressions
  for _ = 1, 2 do
    node = node:parent()
    if not node then
      break
    end
    if hoverworthy_nodes[node:type()] then
      return not is_at_declaration()
    end
  end
  return false
end

local function should_hover()
  if not vim.g.auto_hover_enabled then
    return false
  end
  if vim.fn.mode() ~= "n" then
    return false
  end
  if vim.bo.buftype ~= "" then
    return false
  end
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    return false
  end
  local ok, cmp = pcall(require, "blink.cmp")
  if ok and cmp.is_visible() then
    return false
  end
  if vim.b.lsp_floating_preview then
    return false
  end
  return is_hoverworthy()
end

return {
  {
    "auto-hover",
    virtual = true,
    event = "LspAttach",
    keys = {
      {
        "<leader>uh",
        function()
          vim.g.auto_hover_enabled = not vim.g.auto_hover_enabled
          vim.notify("Auto-hover " .. (vim.g.auto_hover_enabled and "enabled" or "disabled"))
        end,
        desc = "Toggle Auto-Hover",
      },
    },
    init = function()
      vim.g.auto_hover_enabled = true
    end,
    config = function()
      local group = vim.api.nvim_create_augroup("fathom_auto_hover", { clear = true })
      local timer = vim.uv.new_timer()
      local delay = 800 -- ms after CursorHold (on top of updatetime)

      vim.api.nvim_create_autocmd("CursorHold", {
        group = group,
        callback = function()
          if not should_hover() then
            return
          end
          timer:stop()
          timer:start(
            delay,
            0,
            vim.schedule_wrap(function()
              if not should_hover() then
                return
              end
              if _G.deep_hover_request then
                _G.deep_hover_request(0, 2)
              end
            end)
          )
        end,
      })

      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        callback = function()
          timer:stop()
          vim.b.lsp_floating_preview = nil
        end,
      })
    end,
  },
}
