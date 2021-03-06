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

local Object = require('core').Object
local table = require('table')
local string = require('string')
local fs = require('fs')
local path = require('path')

local ProcessInfo = require('./process_info').ProcessInfo

local ProcessScanner = Object:extend()

function ProcessScanner:initialize()
end

function ProcessScanner:getProcesses()
  local result = {}
  local files = fs.readdirSync('/proc/')
  local match

  for _, file in ipairs(files) do
    match = string.match(file, '%d+')
    if match then
      -- Process can die when instantiate it
      local status, pi = pcall(function()
        return ProcessInfo:new(tonumber(file))
      end)

      if status then
        table.insert(result, pi)
      end
    end
  end

  return result
end

local exports = {}
exports.ProcessScanner = ProcessScanner
return exports
