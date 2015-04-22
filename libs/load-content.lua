local pathJoin = require('luvi').path.join
local makeChroot = require('hybrid-fs')

return function (section, name)
  local fs = makeChroot(pathJoin(module.dir, "..", section))
  local content, err
  local path = (name or "index") .. ".md"
  content, err = fs.readFile(path)
  if not content then
    if err and not err:match("^ENOENT:") then error(err) end
    path = (name or "index") .. ".html"
    content, err = fs.readFile(path)
    if not content then
      if err and not err:match("^ENOENT:") then error(err) end
      return
    end
  end
  local meta, extra = content:match("^(%b{})%s*(.*)$")
  local data
  if meta then
    content = extra
    local fn = assert(loadstring("return " .. meta, path))
    setfenv(fn, {})
    data = fn()
  else
    data = {}
  end
  data.content = content
  data.name = name
  data.section = section
  data.path = path
  return data
end
