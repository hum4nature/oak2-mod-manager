B85 = {}
local HANDLE_PREFIX = true
local REVERSE_BITS = true
local BYTE_ORDER = {0, 1, 2, 3}
local B85_CHARSET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{/}~"
local reverseLookup = {}

for i = 1, 256 do
 reverseLookup[i] = 0xFF
end

for i = 1, string.len(B85_CHARSET) do
 local charCode = string.byte(string.sub(B85_CHARSET, i, i))
 reverseLookup[charCode + 1] = i - 1
end

local function byteToBits(byte)
 local bits = {}
 for i = 7, 0, -1 do
  table.insert(bits, (byte >> i) & 1)
 end
 return bits
end

function B85.bytesToHex(bytes)
 if not bytes then return nil; end
 local hexResult = ""
 for i = 1, #bytes do
  hexResult = hexResult .. string.format("%02x", bytes[i])
 end
 return hexResult
end

function B85.hexToBytes(hexString)
 if not hexString then return nil; end
 local bytes = {}
 for i = 1, string.len(hexString), 2 do
  local hexByte = string.sub(hexString, i, i + 1)
  table.insert(bytes, tonumber(hexByte, 16))
 end
 return bytes
end

function B85.bytesToBits(bytes)
 if not bytes then return nil; end
 local bits = {}
 for i = 1, #bytes do
  local byteBits = byteToBits(bytes[i])
  for j = 1, #byteBits do
   table.insert(bits, byteBits[j])
  end
 end
 return bits
end

local function bitsToByte(bits, startIndex)
 if not bits then return nil; end
 local byte = 0
 for i = 0, 7 do
  if startIndex + i <= #bits then
   byte = byte | (bits[startIndex + i] << (7 - i))
  end
 end
 return byte
end

function B85.bitsToBytes(bits)
 if not bits then return nil; end
 local bytes = {}
 for i = 1, #bits, 8 do
  table.insert(bytes, bitsToByte(bits, i))
 end
 return bytes
end

function B85.byteToBinaryString(byte)
 if not byte then return nil; end
 local result = ""
 for i = 7, 0, -1 do
  result = result .. tostring((byte >> i) & 1)
 end
 return result
end

function B85.bytesToBinaryString(bytes)
 if not bytes then return nil; end
 local result = ""
 for i = 1, #bytes do
  result = result .. B85.byteToBinaryString(bytes[i])
  if i < #bytes then
   result = result .. " "
  end
 end
 return result
end

function B85.bitsToBinaryString(bits, groupByBytes)
 if not bits then return nil; end
 local result = ""
 for i = 1, #bits do
  result = result .. tostring(bits[i])
  if groupByBytes and i % 8 == 0 and i < #bits then
   result = result .. " "
  end
 end
 return result
end


function B85.binaryStringToBits(binaryString)
 if not binaryString then return nil; end
 local bits = {}
 local cleanString = string.gsub(binaryString, "%s+", "")
 for i = 1, string.len(cleanString) do
  local char = string.sub(cleanString, i, i)
  if char == "0" then
   table.insert(bits, 0)
  elseif char == "1" then
   table.insert(bits, 1)
  else
   error("Invalid binary string: contains non-binary character '" .. char .. "' at position " .. i)
  end
 end
 return bits
end

B85.setByteOrder = function(newOrder)
 if #newOrder ~= 4 then
  error("Invalid byte order configuration: must have exactly 4 elements")
 end
 local seen = {}
 for _, v in ipairs(newOrder) do
  if v < 0 or v > 3 then
   error("Invalid byte order configuration: values must be 0-3")
  end
  if seen[v] then
   error("Invalid byte order configuration: duplicate values not allowed")
  end
  seen[v] = true
 end
 BYTE_ORDER = {newOrder[1], newOrder[2], newOrder[3], newOrder[4]}
end

function B85.getByteOrder()
 return {BYTE_ORDER[1], BYTE_ORDER[2], BYTE_ORDER[3], BYTE_ORDER[4]}
end

function B85.setReverseBits(value)
 REVERSE_BITS = value
end

function B85.getReverseBits()
 return REVERSE_BITS
end

function B85.setHandlePrefix(value)
 HANDLE_PREFIX = value
end

function B85.getHandlePrefix()
 return HANDLE_PREFIX
end

local function applyByteOrder(bytes)
 return {
  bytes[BYTE_ORDER[1] + 1],
  bytes[BYTE_ORDER[2] + 1],
  bytes[BYTE_ORDER[3] + 1],
  bytes[BYTE_ORDER[4] + 1]
 }
end

local function reverseByteOrder(bytes)
 local result = {0, 0, 0, 0}
 result[BYTE_ORDER[1] + 1] = bytes[1]
 result[BYTE_ORDER[2] + 1] = bytes[2]
 result[BYTE_ORDER[3] + 1] = bytes[3]
 result[BYTE_ORDER[4] + 1] = bytes[4]
 return result
end

local function reverseBits(b)
 b = ((b & 0xF0) >> 4) | ((b & 0x0F) << 4)
 b = ((b & 0xCC) >> 2) | ((b & 0x33) << 2)
 b = ((b & 0xAA) >> 1) | ((b & 0x55) << 1)
 return b
end

local function toUnsigned32(value)
 if value < 0 then
  return value + 0x100000000
 end
 return value
end

B85.decode = function(inputString)
 if not inputString then;
 return;
 end
 local str = inputString
 if HANDLE_PREFIX then
  if string.len(str) < 2 or string.sub(str, 1, 2) ~= "@U" then
   return nil
  end
  str = string.sub(str, 3)
 end
    
 local result = {}
 local idx = 1
 local size = string.len(str)
    
 while idx <= size do
  local workingU32 = 0
  local charCount = 0
  while idx <= size and charCount < 5 do
   local char = string.sub(str, idx, idx)
   local charCode = string.byte(char)
   idx = idx + 1
   if charCode >= 0 and reverseLookup[charCode + 1] < 0x56 then
    workingU32 = workingU32 * 85 + reverseLookup[charCode + 1]
    charCount = charCount + 1
   end
  end
  if charCount == 0 then
   break
  end
  if charCount < 5 then
   local padding = 5 - charCount
   for i = 1, padding do
    workingU32 = workingU32 * 85 + 0x7e -- '~' value
   end
  end
  workingU32 = toUnsigned32(workingU32)
  if charCount == 5 then
   local standardBytes = {
    (workingU32 >> 24) & 0xFF,
    (workingU32 >> 16) & 0xFF,
    (workingU32 >> 8) & 0xFF,
    workingU32 & 0xFF
   }
         
   local orderedBytes = reverseByteOrder(standardBytes)
   table.insert(result, orderedBytes[1])
   table.insert(result, orderedBytes[2])
   table.insert(result, orderedBytes[3])
   table.insert(result, orderedBytes[4])
  else
   local byteCount = charCount - 1
   if byteCount >= 1 then
    table.insert(result, (workingU32 >> 24) & 0xFF)
   end
   if byteCount >= 2 then
    table.insert(result, (workingU32 >> 16) & 0xFF)
   end
   if byteCount >= 3 then
    table.insert(result, (workingU32 >> 8) & 0xFF)
   end
  end
 end
    
 if REVERSE_BITS then
  for i = 1, #result do
   result[i] = reverseBits(result[i])
  end
 end
 
 local hexResult = B85.bytesToHex(result)
 return hexResult, result
end

B85.encode = function(hexString)
 local bytes = type(hexString) =="string" and B85.hexToBytes(hexString) or hexString
 if REVERSE_BITS then
  for i = 1, #bytes do
   bytes[i] = reverseBits(bytes[i])
  end
 end
    
 local result = {}
 local idx = 1
 local len = #bytes
 local extraBytes = len % 4
 local fullGroups = math.floor(len / 4)
    
 for i = 1, fullGroups do
  local inputBytes = {bytes[idx], bytes[idx + 1], bytes[idx + 2], bytes[idx + 3]}
  idx = idx + 4
  local orderedBytes = applyByteOrder(inputBytes)
  local u32 = (orderedBytes[1] << 24) | (orderedBytes[2] << 16) | (orderedBytes[3] << 8) | orderedBytes[4]
  u32 = toUnsigned32(u32)
  table.insert(result, string.sub(B85_CHARSET, math.floor(u32 / 52200625) + 1, math.floor(u32 / 52200625) + 1))
  local rem1 = u32 % 52200625
  table.insert(result, string.sub(B85_CHARSET, math.floor(rem1 / 614125) + 1, math.floor(rem1 / 614125) + 1))
  local rem2 = rem1 % 614125
  table.insert(result, string.sub(B85_CHARSET, math.floor(rem2 / 7225) + 1, math.floor(rem2 / 7225) + 1))
  local rem3 = rem2 % 7225
  table.insert(result, string.sub(B85_CHARSET, math.floor(rem3 / 85) + 1, math.floor(rem3 / 85) + 1))
  table.insert(result, string.sub(B85_CHARSET, (rem3 % 85) + 1, (rem3 % 85) + 1))
 end
    
 if extraBytes ~= 0 then
  local lastU32 = bytes[idx]
  if extraBytes >= 2 then
   lastU32 = (lastU32 << 8) | bytes[idx + 1]
  end
  if extraBytes == 3 then
   lastU32 = (lastU32 << 8) | bytes[idx + 2]
  end
  
  local workingU32
  if extraBytes == 3 then
   workingU32 = lastU32 << 8
  elseif extraBytes == 2 then
   workingU32 = lastU32 << 16
  else
   workingU32 = lastU32 << 24
  end
  workingU32 = toUnsigned32(workingU32)
  
  table.insert(result, string.sub(B85_CHARSET, math.floor(workingU32 / 52200625) + 1, math.floor(workingU32 / 52200625) + 1))
  local rem1 = workingU32 % 52200625
  table.insert(result, string.sub(B85_CHARSET, math.floor(rem1 / 614125) + 1, math.floor(rem1 / 614125) + 1))
  
  if extraBytes >= 2 then
   local rem2 = rem1 % 614125
   table.insert(result, string.sub(B85_CHARSET, math.floor(rem2 / 7225) + 1, math.floor(rem2 / 7225) + 1))
   if extraBytes == 3 then
    local rem3 = rem2 % 7225
    table.insert(result, string.sub(B85_CHARSET, math.floor(rem3 / 85) + 1, math.floor(rem3 / 85) + 1))
   end
  end
 end
 local resultString = table.concat(result)
 if HANDLE_PREFIX then
  return "@U" .. resultString, result
 else
  return resultString, result
 end
end


local LEVEL_MARKER = '00000011001000001100'

local function findSubstring(str, pattern)
 local pos = string.find(str, pattern, 1, true)
 return pos and (pos - 1) or -1
end

local function sliceString(str, startIndex, endIndex)
 if endIndex then
  return string.sub(str, startIndex + 1, endIndex)
 else
  return string.sub(str, startIndex + 1)
 end
end

local function reverseString(str)
 return string.reverse(str)
end

local function binaryToSignedInt(binaryStr)
 if #binaryStr == 0 then
  return 0
 end
 local value = tonumber(binaryStr, 2)
 if not value then
  return 0
 end
 if #binaryStr > 0 and string.sub(binaryStr, 1, 1) == '1' then
  value = value - (1 << #binaryStr)
 end
 return value
end

local function signedIntToBinary(value, bitLength)
 bitLength = bitLength or 16
 if value < 0 then
  value = value + (1 << bitLength)
 end
 local binaryStr = ""
 for i = bitLength - 1, 0, -1 do
  binaryStr = binaryStr .. ((value >> i) & 1)
 end
 return binaryStr
end

function B85.itemDecodeLevel(binaryString)
 if binaryString==nil then;return nil;end
 local b02 = type(binaryString)=="string" and binaryString or B85.bitsToBinaryString(binaryString);
 if #b02 >= 200 then
  b02 = sliceString(b02, 0, 200)
 end
 local firstLevelBit = -1
 local lastLevelBit = -1
 local markerIndex = findSubstring(b02, LEVEL_MARKER)
 if markerIndex == -1 then
  return nil
 end
 firstLevelBit = markerIndex + #LEVEL_MARKER
 b02 = sliceString(b02, markerIndex + #LEVEL_MARKER)
 if #b02 >= 20 then
  b02 = sliceString(b02, 0, 20)
 end
 local levelBits = ''
 lastLevelBit = firstLevelBit
 
 while #b02 > 0 do
  if #b02 < 5 then
   return nil
  end
  lastLevelBit = lastLevelBit + 5
  local block = sliceString(b02, 0, 5)
  local dataBits = sliceString(block, 0, 4)
  local continuationFlag = string.sub(block, 5, 5)
  levelBits = levelBits .. dataBits
  if continuationFlag == '0' then
   break
  end
  b02 = sliceString(b02, 5)
 end
 
 levelBits = reverseString(levelBits)
 
 while #levelBits < 16 do
  levelBits = '0' .. levelBits
 end
 
 local level = binaryToSignedInt(levelBits)
 return {
  level = level,
  firstLevelBit = firstLevelBit,
  lastLevelBit = lastLevelBit,
  levelBitCount = lastLevelBit - firstLevelBit
 }
end

function B85.itemEncodeLevel(newLevel, originalBinaryString)
 if originalBinaryString==nil then;return nil;end
 local RetString = type(originalBinaryString) == "string"
 local originalBinary = RetString and originalBinaryString or B85.bitsToBinaryString(originalBinaryString)
 
 local markerIndex = findSubstring(originalBinary, LEVEL_MARKER)
 if markerIndex == -1 then
  return nil, "Level marker not found"
 end
 
 local beforeMarker = string.sub(originalBinary, 1, markerIndex + #LEVEL_MARKER)
 
 local originalLevelInfo = B85.itemDecodeLevel(originalBinary)
 if not originalLevelInfo then
  return nil, "Failed to decode original level"
 end
 
 local levelBinary = signedIntToBinary(newLevel, 16)
 local reversedLevelBinary = reverseString(levelBinary)
 
 local lastOneBit = 0
 for i = 1, #reversedLevelBinary do
  if string.sub(reversedLevelBinary, i, i) == '1' then
   lastOneBit = i
  end
 end
 
 if lastOneBit == 0 then
  lastOneBit = 1
 end
 
 local trimmedBits = string.sub(reversedLevelBinary, 1, lastOneBit)
 local encodedLevel = ""
 local pos = 1
 
 while pos <= #trimmedBits do
  local dataBits = string.sub(trimmedBits, pos, pos + 3)
  local actualBitCount = #dataBits
  while #dataBits < 4 do
   dataBits = dataBits .. "0"
  end
  pos = pos + actualBitCount
  local continuationFlag = (pos <= #trimmedBits) and "1" or "0"
  encodedLevel = encodedLevel .. dataBits .. continuationFlag
 end
 
 local afterLevel = ""
 if originalLevelInfo.lastLevelBit < #originalBinary then
  afterLevel = string.sub(originalBinary, originalLevelInfo.lastLevelBit + 1)
 end
 local newBinaryString = beforeMarker .. encodedLevel .. afterLevel
 if not RetString then
  return B85.binaryStringToBits(newBinaryString)
 end
 return newBinaryString
end

function B85.decodeItemLevelFromParts(partsString)
 if partsString==nil then;return nil;end
 if not partsString or partsString == "" then
  return nil
 end
 local hexResult, bytes = B85.decode(partsString)
 if not bytes then
  return nil
 end
 local bits = B85.bytesToBits(bytes)
 local binaryString = B85.bitsToBinaryString(bits)
 return B85.itemDecodeLevel(binaryString)
end

function B85.encodeItemLevelInParts(partsString, newLevel)
 if not partsString or partsString == "" then
  return nil, "Invalid parts string"
 end
 
 local hexResult, bytes = B85.decode(partsString)
 if not bytes then
  return nil, "Failed to decode parts string"
 end
 
 local bits = B85.bytesToBits(bytes)
 local originalBinaryString = B85.bitsToBinaryString(bits)
 local newBinaryString = B85.itemEncodeLevel(newLevel, originalBinaryString)
 
 if not newBinaryString then
  return nil, "Failed to encode new level"
 end
 
 local newBits = B85.binaryStringToBits(newBinaryString)
 
 while #newBits % 8 ~= 0 do
  table.insert(newBits, 0)
 end
 
 local newBytes = B85.bitsToBytes(newBits)
 local newPartsString = B85.encode(newBytes)
 return newPartsString
end

