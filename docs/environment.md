# Environment

This is the environment being passed to Alfonsfiles, along with everything on `provide`.

```moon
ENVIRONMENT = {
  :_VERSION
  :assert, :error, :pcall, :xpcall
  :tonumber, :tostring
  :select, :type, :pairs, :ipairs, :next, :unpack
  :require
  :print, :style                        -- from ansikit
  :io, :math, :string, :table, :os, :fs -- fs is either CC/fs or filekit
}
```