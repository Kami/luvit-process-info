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
local fs = require('fs')
local path = require('path')
local string = require('string')
local fmt = require('string').format

local async = require('async')

local split = require('../util').split
local trim = require('../util').trim

local DEFAULT_PROC_PATH = '/proc/'
local ProcessInfo = Object:extend()

function ProcessInfo:initialize(pid, options)
  assert(type(pid) == 'number', 'Pid must be a number')
  assert(pid > 0, 'Pid mud be greater than 0')

  options = options and options or {}
  local procPath = options.procPath and options.procPath or DEFAULT_PROC_PATH
  local processProcPath = path.join(procPath, tostring(pid))

  if not fs.existsSync(procPath) then
    error('Invalid procPath: ' .. procPath)
  end

  if not fs.existsSync(processProcPath) then
    error('Invalid pid: ' .. pid)
  end

  self._pid = pid
  self._procPath = processProcPath
end

ProcessInfo.meta.__tostring = function(self)
  return fmt('<ProcessInfo pid=%s>', self._pid)
end

function ProcessInfo:getPid()
  return self._pid
end

function ProcessInfo:getPpid()
  local status = self:_getStatus()
  return tonumber(status['PPid'])
end

function ProcessInfo:getCwd()
  local filePath = path.join(self._procPath, 'cwd')
  return fs.readlinkSync(filePath)
end

function ProcessInfo:getExe()
  local filePath = path.join(self._procPath, 'exe')
  return fs.readlinkSync(filePath)
end

function ProcessInfo:getCmdline()
  return self:_getProcFileContent('cmdline')
end

function ProcessInfo:getEnviron()
  local data, lines, pair, result

  result = {}
  data = self:_getProcFileContent('environ')
  lines = split(data, '[^%z]+')

  for index, line in ipairs(lines) do
    pair = split(line, '[^=]+')
    result[pair[1]] = pair[2]
  end

  return result
end

function ProcessInfo:_getStatus()
  local data, lines, pair, result

  result = {}
  data = self:_getProcFileContent('status')
  lines = split(data, '[^\n]+')

  for index, line in ipairs(lines) do
    pair = split(line, '[^:]+')
    result[pair[1]] = trim(pair[2])
  end

  return result
end

function ProcessInfo:_getProcFileContent(file)
  local filePath = path.join(self._procPath, file)
  return self:_getFileContent(filePath)
end

function ProcessInfo:_getFileContent(filePath)
  local content = fs.readFileSync(filePath)
  return content
end

local exports = {}
exports.ProcessInfo = ProcessInfo
return exports
