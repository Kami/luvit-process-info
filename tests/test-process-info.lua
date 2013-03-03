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

local path = require('path')

local ProcessInfo = require('../lib/process_info').ProcessInfo

local exports = {}

exports['test_invalid_pid'] = function(test, asserts)
  local status, err = pcall(function()
    ProcessInfo:new(1989899)
  end)

  asserts.ok(err:find('Invalid pid: 1989899') ~= nil)
  test.done()
end

exports['test_invalid_pid_not_a_number'] = function(test, asserts)
  local status, err = pcall(function()
    ProcessInfo:new('abcd')
  end)

  asserts.ok(err:find('Pid must be a number') ~= nil)
  test.done()
end

exports['test_invalid_pid_negative_pid'] = function(test, asserts)
  local status, err = pcall(function()
    ProcessInfo:new(-1)
  end)

  asserts.ok(err:find('Pid must be greater than 0') ~= nil)
  test.done()
end

exports['test_ProcessInfo'] = function(test, asserts)
  local procPath = path.join(process:cwd(), 'tests/fixtures/proc1')
  local pi = ProcessInfo:new(1234, {procPath=procPath})
  local environ = {SSH_AGENT_PID='2168', COLORTERM='gnome-terminal',
                   XAUTHORITY='/home/foo/.Xauthority',
                   _='/usr/bin/irssi'}

  asserts.equal(pi:getPid(), 1234)
  asserts.equal(pi:getPpid(), 3100)
  asserts.equal(pi:getExe(), 'irssi')
  asserts.equal(pi:getCwd(), '.')
  asserts.equal(pi:getCmdline(), 'irssi -s irc.freenode.net')
  asserts.dequals(pi:getEnviron(), environ)
  test.done()
end

return exports
