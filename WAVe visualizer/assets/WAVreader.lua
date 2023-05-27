-- https://docs.fileformat.com/audio/wav/

-- https://web.archive.org/web/20110719132013/http://hazelware.luggle.com/tutorials/mulawcompression.html
MU_LAW_DECOMPRESS_TABLE = {
	-32124,-31100,-30076,-29052,-28028,-27004,-25980,-24956,
	-23932,-22908,-21884,-20860,-19836,-18812,-17788,-16764,
	-15996,-15484,-14972,-14460,-13948,-13436,-12924,-12412,
	-11900,-11388,-10876,-10364, -9852, -9340,-8828, -8316,
	-7932, -7676, -7420, -7164, -6908, -6652, -6396, -6140,
	-5884, -5628, -5372, -5116, -4860, -4604, -4348, -4092,
	-3900, -3772, -3644, -3516, -3388, -3260, -3132, -3004,
	-2876, -2748, -2620, -2492, -2364, -2236, -2108, -1980,
	-1884, -1820, -1756, -1692, -1628, -1564, -1500, -1436,
	-1372, -1308, -1244, -1180, -1116, -1052, -988,  -924,
	-876,  -844,  -812,  -780,  -748,  -716,  -684,  -652,
	-620,  -588,  -556,  -524,  -492,  -460,  -428,  -396,
	-372,  -356,  -340,  -324,  -308,  -292,  -276,  -260,
	-244,  -228,  -212,  -196,  -180,  -164,  -148,  -132,
	-120,  -112,  -104,  -96,   -88,   -80,   -72,   -64,
	-56,   -48,   -40,   -32,   -24,   -16,   -8,    -1,
	32124, 31100, 30076, 29052, 28028, 27004, 25980, 24956,
	23932, 22908, 21884, 20860, 19836, 18812, 17788, 16764,
	15996, 15484, 14972, 14460, 13948, 13436, 12924, 12412,
	11900, 11388, 10876, 10364, 9852,  9340,  8828,  8316,
	7932,  7676,  7420,  7164,  6908,  6652,  6396,  6140,
	5884,  5628,  5372,  5116,  4860,  4604,  4348,  4092,
	3900,  3772,  3644,  3516,  3388,  3260,  3132,  3004,
	2876,  2748,  2620,  2492,  2364,  2236,  2108,  1980,
	1884,  1820,  1756,  1692,  1628,  1564,  1500,  1436,
	1372,  1308,  1244,  1180,  1116,  1052,  988,   924,
	876,   844,   812,   780,   748,   716,   684,   652,
	620,   588,   556,   524,   492,   460,   428,   396,
	372,   356,   340,   324,   308,   292,   276,   260,
	244,   228,   212,   196,   180,   164,   148,   132,
	120,   112,   104,   96,    88,    80,    72,    64,
	56,    48,    40,    32,    24,    16,    8,     0
}

ALAW_DECOMPRESS_TABLE = {
	-5504, -5248, -6016, -5760, -4480, -4224, -4992, -4736,
	-7552, -7296, -8064, -7808, -6528, -6272, -7040, -6784,
	-2752, -2624, -3008, -2880, -2240, -2112, -2496, -2368,
	-3776, -3648, -4032, -3904, -3264, -3136, -3520, -3392,
	-22016,-20992,-24064,-23040,-17920,-16896,-19968,-18944,
	-30208,-29184,-32256,-31232,-26112,-25088,-28160,-27136,
	-11008,-10496,-12032,-11520,-8960, -8448, -9984, -9472,
	-15104,-14592,-16128,-15616,-13056,-12544,-14080,-13568,
	-344,  -328,  -376,  -360,  -280,  -264,  -312,  -296,
	-472,  -456,  -504,  -488,  -408,  -392,  -440,  -424,
	-88,   -72,   -120,  -104,  -24,   -8,    -56,   -40,
	-216,  -200,  -248,  -232,  -152,  -136,  -184,  -168,
	-1376, -1312, -1504, -1440, -1120, -1056, -1248, -1184,
	-1888, -1824, -2016, -1952, -1632, -1568, -1760, -1696,
	-688,  -656,  -752,  -720,  -560,  -528,  -624,  -592,
	-944,  -912,  -1008, -976,  -816,  -784,  -880,  -848,
	5504,  5248,  6016,  5760,  4480,  4224,  4992,  4736,
	7552,  7296,  8064,  7808,  6528,  6272,  7040,  6784,
	2752,  2624,  3008,  2880,  2240,  2112,  2496,  2368,
	3776,  3648,  4032,  3904,  3264,  3136,  3520,  3392,
	22016, 20992, 24064, 23040, 17920, 16896, 19968, 18944,
	30208, 29184, 32256, 31232, 26112, 25088, 28160, 27136,
	11008, 10496, 12032, 11520, 8960,  8448,  9984,  9472,
	15104, 14592, 16128, 15616, 13056, 12544, 14080, 13568,
	344,   328,   376,   360,   280,   264,   312,   296,
	472,   456,   504,   488,   408,   392,   440,   424,
	88,    72,    120,   104,   24,    8,     56,    40,
	216,   200,   248,   232,   152,   136,   184,   168,
	1376,  1312,  1504,  1440,  1120,  1056,  1248,  1184,
	1888,  1824,  2016,  1952,  1632,  1568,  1760,  1696,
	688,   656,   752,   720,   560,   528,   624,   592,
	944,   912,   1008,  976,   816,   784,   880,   848
}

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
	assert(fileFormat == "RIFF" or fileFormat == "WAVE", `File format must be RIFF or WAV, but was: {fileFormat}`)
	
	file:seek("cur", 4) -- skip file size
	local typeHeader = readStr(file, 4)
	assert(typeHeader == 'WAVE', 'Incorrect file format')
	
	local formatChunk = readStr(file, 4)
	assert(formatChunk == 'fmt ', 'Incorrect file format')
	
	local hsize			= readUInt(file, 4)  -- length of format data as listed above
	local audioFormat	= readUInt(file, 2) -- 1 = PCM, 3 = IEEE float, 6 = mu-law, 7=a-law, 257 = IBM Mu-Law, 258 = IBM A-Law, 259=ADPCM
	local channelNum	= readUInt(file, 2) -- Number of channels 1=Mono 2=Sterio
	local samplesPerSec	= readUInt(file, 4) -- in Hz
	local bytesPerSec	= readUInt(file, 4)
	local blockAlign	= readUInt(file, 2) -- 2=16-bit mono, 4=16-bit stereo
	local bitsPerSample	= readUInt(file, 2)
	
	log(`headerSize:	{headerSize}`)
	log(`fileFormat:	{fileFormat}`)
	log(`audioFormat:	{audioFormat}`)
	log(`channelNum:	{channelNum}`)
	log(`samplesPerSec:	{samplesPerSec}`)
	log(`bytesPerSec:	{bytesPerSec}`)
	log(`blockAlign:	{blockAlign}`)
	log(`bitsPerSample:	{bitsPerSample}`)
	
	self.channelNum = channelNum
	self.ampMin =  1000000
	self.ampMax = -1000000
	
	if hsize ~= 16 then
		file:seek("cur", hsize - 16)
	end
	log(`Seek: {file:seek()}`)
	
	-- look for 'fact' chunk (every none PCM format)
	-- TODO?
	
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
		-- PCM
		if audioFormat == 1 then
			if bitsPerSample == 8 then
				local bytes = string.unpack(`{INDIAN_PREFIX}B`, data, i)
				i += 1
				sample = (bytes - 128) / 255
			elseif bitsPerSample == 16 then
				local bytes = string.unpack(`{INDIAN_PREFIX}h`, data, i)
				i += 2
				sample = bytes / 0x7FFF
			elseif bitsPerSample == 24 then
				local bytes = string.unpack(`{INDIAN_PREFIX}i3`, data, i)
				i += 3
				sample = bytes/ 0x7FFFFF
			elseif bitsPerSample == 32 then
				local bytes = string.unpack(`{INDIAN_PREFIX}i4`, data, i)
				i += 4
				sample = bytes/ 0x7FFFFFFF
			end
		-- IEEE Float
		elseif audioFormat == 3 then
			-- 32 bit floating point ('float' data type)
			if bitsPerSample == 32 then
				sample = string.unpack(`{INDIAN_PREFIX}f`, data, i)
				i += 4
			-- 64 bit floating point ('double' data type)
			elseif bitsPerSample == 64 then
				sample = string.unpack(`{INDIAN_PREFIX}d`, data, i)
				i += 8
			end
		-- A-Law
		elseif audioFormat == 6 then
			local bytes = string.unpack(`{INDIAN_PREFIX}b`, data, i)
			i += 1
			sample = MU_LAW_DECOMPRESS_TABLE[bytes + 129] / 0x7FFF
		-- Mu-Law
		elseif audioFormat == 7 then
			local bytes = string.unpack(`{INDIAN_PREFIX}b`, data, i)
			i += 1
			sample = ALAW_DECOMPRESS_TABLE[bytes + 129] / 0x7FFF
		end
		
		self.ampMin = sample >< self.ampMin
		self.ampMax = sample <> self.ampMax
		self.samples[sampleIdx] = sample
		
		sampleIdx += 1
	end
	
	log(`Amp (min): {self.ampMin}`)
	log(`Amp (max): {self.ampMax}`)
end