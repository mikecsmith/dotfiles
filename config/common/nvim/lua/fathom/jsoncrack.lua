local M = {}

function M.open_in_jsoncrack()
  local ft = vim.bo.filetype
  if ft ~= "json" and ft ~= "yaml" and ft ~= "yml" then
    vim.notify("Filetype must be JSON or YAML", vim.log.levels.ERROR)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  local html = [[
  <section>
    <iframe id="jsoncrackEmbed" src="http://localhost:3000/widget" width="100%" height="100%"></iframe>
    <script>
      window.onload = function() {
        const jsonCrackEmbed = document.getElementById("jsoncrackEmbed");
        const data = `]] .. content:gsub("`", "\\`") .. [[`;
        const options = {
          theme: "light",
          direction: "RIGHT"
        };
        jsonCrackEmbed.onload = function() {
          jsonCrackEmbed.contentWindow.postMessage({ csv: data, options }, "*");
        };
      }
    </script>
  </section>
  ]]

  local tmpfile = vim.fn.tempname() .. ".html"
  local f = io.open(tmpfile, "w")
  f:write(html)
  f:close()
  vim.fn.jobstart({ "open", tmpfile }, { detach = true })
end

return M
