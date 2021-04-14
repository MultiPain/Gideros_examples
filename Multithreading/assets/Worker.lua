--!NOEXEC

if (not  Thread) then 
	require "Threads"
end

Worker = Core.class()

function Worker:init(numThreads)
	self.threadsCount = numThreads
	
	-- holds all threads objects
	self.threads = {}
	
	-- how many working threads we have
	self.workingCount = 0
	-- working threads itselfs
	self.workingThreads = {}
	
	-- holds functions AND arguments to pass to this functions
	self.queue = {}
	
	for i = 1, self.threadsCount do 
		self.threads[i] = Thread.new()
	end
end
--
function Worker:pushTask(task, ...)
	-- if we have free thread, use it
	if (self.workingCount < self.threadsCount) then 
		for i = 1, self.threadsCount do 
			local thread = self.threads[i]
			local status = thread:status()
			if (status == "complete" or status == "needs function") then 
				thread:setFunction(task)
				local ok = thread:execute(...)
				if (ok) then 
					self.workingCount += 1
					self.workingThreads[self.workingCount] = thread
				else
					error(("Cant start a thread! Thread #%d status: %s"):format(i, status))
				end
				return
			end
		end
	-- otherwise add to queue to execute later
	else
		local taskArgs = { ... }
		-- add function ad the end of arguments table
		taskArgs[#taskArgs + 1] = task
		-- add task to queue
		self.queue[#self.queue + 1] = taskArgs
	end
end
-- wait for queue to finish
function Worker:wait()
	-- local reference to a table to save some time
	local workingThreads = self.workingThreads
	local len = self.workingCount
	
	local queue = self.queue
	local qlen = #queue
	
	local results = {}
	
	-- waiting for all worker threads to complete their task
	while (len >= 1) do 
		local i = len
		while (i >= 1) do 
			local thread = workingThreads[i]
			local ok, result = thread:getResult()
			-- thread is finished
			if (ok) then 
				-- add task result to a table
				results[#results + 1] = result
				
				-- if we have tasks to execute
				if (qlen > 0) then 
					-- get last pushed task
					local taskArgs = queue[qlen]
					-- get amount of argument for the task
					local tlen = #taskArgs
					-- get the task function 
					local task = taskArgs[tlen]
					-- remove it from array
					taskArgs[tlen] = nil
					-- attach task function to a thread
					thread:setFunction(task)
					-- try to run thread with given args
					local ok = thread:execute(unpack(taskArgs))
					if (ok) then 
						-- remove task from the queue
						queue[qlen] = nil
						qlen -= 1
					else
						error(("Cant start a thread! Thread #%d status: %s"):format(i, status))
					end
				else
					-- no more queued tasks, remove from list
					len -= 1
					table.remove(workingThreads, i)
				end
			end
			
			i -= 1
		end
	end
	self.workingCount = 0
	
	return results
end
--