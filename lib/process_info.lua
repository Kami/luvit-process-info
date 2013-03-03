--[[
Copyright Tomaz Muraus

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--]]

local os = require('os')
local osType = os.type():lower()

local exports = {}

if osType ~= 'linux' then
  error('Unsupported OS: ' .. osType)
end

if osType == 'linux' then
  exports.ProcessInfo = require('./platforms/linux').ProcessInfo
end

return exports
