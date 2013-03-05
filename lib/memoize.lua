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

function memoize(key, cache, func, ...)
  local result

  result = func(...)
  cache[key] = result

  return result
end

function memoizeOrGetFromCache(key, cache, func, ...)
  if cache[key] ~= nil then
    return cache[key]
  end

  return memoize(key, cache, func, ...)
end

local exports = {}
exports.memoize = memoize
exports.memoizeOrGetFromCache = memoizeOrGetFromCache
return exports
