local M = {}
local ui = require("cfhelper.CFRun_ui")

local function normalize_file(file)
	local lines = {}
	local f = io.open(file, "r")
	if not f then
		return
	end
	for line in f:lines() do
		line = line:gsub("%s+$", "")
		table.insert(lines, line)
	end
	f:close()

	f = io.open(file, "w")
	if not f then
		return
	end
	for _, line in ipairs(lines) do
		f:write(line, "\n")
	end
	f:close()
end

function M.run()
	local cpp_file = vim.fn.expand("%:p")
	local file_dir = vim.fn.expand("%:p:h")
	local helper_dir = file_dir .. "/.cfhelper"
	vim.fn.mkdir(helper_dir, "p")

	local exec = helper_dir .. "/CFResult.out"
	local compile_cmd = string.format("g++ -o %s %s", exec, cpp_file)
	local compile_output = vim.fn.system(compile_cmd)

	if vim.v.shell_error ~= 0 then
		local error_path = helper_dir .. "/compile_error.txt"
		local f = io.open(error_path, "w")
		if f then
			f:write(compile_output)
			f:close()
		end
		vim.notify("Compilation failed. See .cfhelper/compile_error.txt", vim.log.levels.ERROR)
		return
	end

	local results = {}
	local i = 1
	while true do
		local input_file = string.format("%s/input%d.txt", helper_dir, i)
		local output_file = string.format("%s/output%d.txt", helper_dir, i)
		if vim.fn.filereadable(input_file) == 0 or vim.fn.filereadable(output_file) == 0 then
			break
		end

		local result_file = string.format("%s/result%d.txt", helper_dir, i)
		local run_cmd = string.format("%s < %s > %s", exec, input_file, result_file)
		os.execute(run_cmd)

		normalize_file(output_file)
		normalize_file(result_file)

		-- Read expected and actual lines
		local expected_lines = {}
		local actual_lines = {}

		local f = io.open(output_file, "r")
		if f then
			for line in f:lines() do
				table.insert(expected_lines, line)
			end
			f:close()
		end

		f = io.open(result_file, "r")
		if f then
			for line in f:lines() do
				table.insert(actual_lines, line)
			end
			f:close()
		end

		-- Check if all lines match
		local is_pass = true
		if #expected_lines ~= #actual_lines then
			is_pass = false
		else
			for idx = 1, #expected_lines do
				if expected_lines[idx] ~= actual_lines[idx] then
					is_pass = false
					break
				end
			end
		end

		-- Add test case header
		local status = is_pass and "pass" or "fail"
		local header = string.format("Test case #%d: %s", i, is_pass and "Passed" or "Failed")
		table.insert(results, { line = header, status = status })

		if status == "fail" then
			-- Add all expected lines
			for _, line in ipairs(expected_lines) do
				table.insert(results, { line = "Expected: " .. line, status = "info" })
			end

			-- Add all output lines
			for _, line in ipairs(actual_lines) do
				table.insert(results, { line = "Output:   " .. line, status = "info" })
			end

			-- Add blank line
			table.insert(results, { line = "", status = "info" })
		end

		i = i + 1
	end

	if #results == 0 then
		table.insert(results, { line = "No test cases found.", status = "info" })
	else
		-- Remove final trailing blank line
		if results[#results] and results[#results].line == "" then
			table.remove(results, #results)
		end
	end

	ui.show_results(results)
end

return M
