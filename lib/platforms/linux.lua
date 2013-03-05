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
local bind = require('utils').bind

local async = require('async')

local split = require('../util').split
local trim = require('../util').trim
local memoize = require('../memoize')

local DEFAULT_PROC_PATH = '/proc/'
local ProcessInfo = Object:extend()

function ProcessInfo:initialize(pid, options)
  assert(type(pid) == 'number', 'Pid must be a number')
  assert(pid > 0, 'Pid must be greater than 0')

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

function ProcessInfo:getAsTable(keys, ignoreErrors)
  local values, result, status, value

  if not keys then
    keys = {'pid', 'ppid', 'exe', 'cwd', 'cmdline'}
  end

  values = {
    ['pid'] = 'getPid',
    ['ppid'] = 'getPpid',
    ['exe'] = 'getExe',
    ['cwd'] = 'getCwd',
    ['cmdline'] = 'getCmdline'
  }

  result = {}

  for _, key in ipairs(keys) do
    if values[key] == nil then
      error('Invalid key: ' .. key)
    end

    funcName = values[key]
    status, value = pcall(bind(self[funcName], self))

    if status then
      result[key] = value
    else
      if not ignoreErrors then
        error(value)
      end
    end
  end

  return result
end

function ProcessInfo:getPid()
  return self._pid
end

function ProcessInfo:getPpid()
  return memoize.memoizeOrGetFromCache('__ppid', self, function()
    local status = self:_getStatus()
    return tonumber(status['PPid'])
  end)
end

function ProcessInfo:getCwd()
  return memoize.memoizeOrGetFromCache('__cwd', self, function()
    local filePath = path.join(self._procPath, 'cwd')
    return fs.readlinkSync(filePath)
  end)
end

function ProcessInfo:getExe()
  return memoize.memoizeOrGetFromCache('__exe', self, function()
    local filePath = path.join(self._procPath, 'exe')
    return fs.readlinkSync(filePath)
  end)
end

function ProcessInfo:getCmdline()
  return memoize.memoizeOrGetFromCache('__cmdline', self, function()
    local data = self:_getProcFileContent('cmdline')
    return self:_cleanLine(data)
  end)
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
  local content = self:_getFileContent(filePath)
  return content
end

function ProcessInfo:_getFileContent(filePath)
  local content = fs.readFileSync(filePath)
  return content
end

function ProcessInfo:_cleanLine(line)
  return trim(line:gsub('%z', ''))
end

local exports = {}
exports.ProcessInfo = ProcessInfo
return exports
