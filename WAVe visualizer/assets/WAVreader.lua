-- https://docs.fileformat.com/audio/wav/

USE_LITTLE_INDIAN = true

if USE_LITTLE_INDIAN then
	INDIAN_PREFIX = '<'
else
	INDIAN_PREFIX = '>'
end

WAVreader = Core.class()

local function log(...)
	local date = os.date("%d.%m.%y %X")
	print(`[{date}] WAV reader: `, ...)
end

local function readUInt(file, bytes)
	-- https://www.lua.org/manual/5.3/manual.html#6.4.2
	local data = file:read(bytes)
	return string.unpack(`{INDIAN_PREFIX}I{bytes}`, data, 0)
end

local function readStr(file, bytes)
	local data = file:read(bytes)
	return string.unpack(`c{bytes}`, data, 0)
end

function WAVreader:init(path)
	if path ~= nil and type(path) == 'string' then
		self:read(path)
	end
end

function WAVreader:read(path)
	log(`Reading file: {path}`)
	
	local file, errorMsg = io.open(path, "rb")
	assert(file, errorMsg)	
	local fileFormat = readStr(file, 4)	
	assert(fileFormat == "RIFF" or fileFormat == "WAVE", `File format must RIFF or WAV, but was: {fileFormat}`)
	
	file:read(12) -- ignore some unused values (TODO: check for 'fmt '?)
	file:read(4)  -- length of format data as listed above (TODO)
	local headerSize = 44 -- TODO: change this according to 4 bytes above
	
	local audioFormat	= readUInt(file, 2) -- 1 = PCM, 6 = mulaw, 7=alaw, 257 = IBM Mu-Law, 258 = IBM A-Law, 259=ADPCM
	local channelNum	= readUInt(file, 2) -- Number of channels 1=Mono 2=Sterio
	local samplesPerSec	= readUInt(file, 4) -- in Hz
	local bytesPerSec	= readUInt(file, 4)
	local blockAlign	= readUInt(file, 2) -- 2=16-bit mono, 4=16-bit stereo
	local bitsPerSample	= readUInt(file, 2)
	
	log(`headerSize:	{headerSize}`)
	log(`fileFormat:	{fileFormat}`)
	log(`dataOffset:	{dataOffset}`)
	log(`audioFormat:	{audioFormat}`)
	log(`channelNum:	{channelNum}`)
	log(`samplesPerSec: {samplesPerSec}`)
	log(`bytesPerSec:	{bytesPerSec}`)
	log(`blockAlign:	{blockAlign}`)
	log(`bitsPerSample: {bitsPerSample}`)
	
	self.channelNum = channelNum
	self.ampMin =  1000000
	self.ampMax = -1000000
	
	-- look for 'data' chunk
	local chunkID = 0
	local chunkSize = 0
	
	while true do
		chunkID		= readUInt(file, 4) 
		chunkSize	= readUInt(file, 4)
		
		-- check for 'data' marker ( string.char(0x64, 0x61, 0x74, 0x61) == 'data' )
		if chunkID == 0x61746164 then
			break
		end
		
		file:seek("cur", chunkSize)
	end
	
	log(`chunkSize: {chunkSize}`)
	
	local data = file:read(chunkSize)
	
	file:close()
	
	-- read actual data
	local samplesCount = chunkSize * 8 / bitsPerSample
    self.samples = table.create(samplesCount, 0)
	
    local i = 1
    local sampleIdx = 1
	
	while i <= chunkSize do
		if sampleIdx >= samplesCount then
			break
		end
		
		local sample = 0
		if audioFormat == 1 then
			if (bitsPerSample == 8) then
				local bytes = string.unpack(`{INDIAN_PREFIX}b`, data, i)
				i += 1
				sample = (bytes - 128) / 255
			elseif (bitsPerSample == 16) then
				local bytes = string.unpack(`{INDIAN_PREFIX}h`, data, i)
				i += 2
				sample = bytes / 32767
			end
		elseif audioFormat == 3 then
			if bitsPerSample == 32 then
				sample = string.unpack(`{INDIAN_PREFIX}l`, data, i)
				i += 4
			end
		end
		
		self.ampMin = sample >< self.ampMin
		self.ampMax = sample <> self.ampMax
		self.samples[sampleIdx] = sample
		
		sampleIdx += 1
	end
	
	log(`Amp (min): {self.ampMin}`)
	log(`Amp (max): {self.ampMax}`)
end