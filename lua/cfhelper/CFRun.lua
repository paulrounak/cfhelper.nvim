local M = {}

-- Ensure result and output files end with a newline
local function ensure_trailing_newline(file)
	local f = io.open(file, "r+")
	if not f then
		return
	end
	local content = f:read("*a")
	if not content:match("\n$") then
		f:seek("end")
		f:write("\n")
	end
	f:close()
end

function M.run()
	local cpp_file = vim.fn.expand("%:p")
	local file_dir = vim.fn.expand("%:p:h")
	local helper_dir = file_dir .. "/.cfhelper"
	local exec = helper_dir .. "/CFResult.out"

	vim.fn.mkdir(helper_dir, "p")

	local compile_cmd = string.format("g++ -o %s %s", exec, cpp_file)
	local compile_output = vim.fn.system(compile_cmd)

	if vim.v.shell_error ~= 0 then
		local error_path = helper_dir .. "/compile_error.txt"
		local f = io.open(error_path, "w")
		if f then
			f:write(compile_output)
			f:close()
			vim.notify("Compilation failed. See .cfhelper/compile_error.txt", vim.log.levels.ERROR)
		else
			vim.notify("Compilation failed and couldn't write error file.", vim.log.levels.ERROR)
		end
		return
	end

	-- Run tests
	local passed, total = 0, 0
	for i = 1, 100 do
		local input_path = string.format("%s/input%d.txt", helper_dir, i)
		local output_path = string.format("%s/output%d.txt", helper_dir, i)
		local result_path = string.format("%s/result%d.txt", helper_dir, i)

		if vim.fn.filereadable(input_path) == 0 or vim.fn.filereadable(output_path) == 0 then
			break
		end

		local run_cmd = string.format("%s < %s > %s", exec, input_path, result_path)
		os.execute(run_cmd)

		ensure_trailing_newline(output_path)
		ensure_trailing_newline(result_path)

		local diff_cmd = string.format("diff -q %s %s", output_path, result_path)
		vim.fn.system(diff_cmd)

		total = total + 1
		if vim.v.shell_error == 0 then
			vim.notify(string.format("Test %d: Passed", i), vim.log.levels.INFO)
			passed = passed + 1
		else
			local diff_output = vim.fn.system(string.format("diff %s %s", output_path, result_path))
			vim.notify(string.format("Test %d: Failed\n%s", i, diff_output), vim.log.levels.WARN)
		end
	end

	if total == 0 then
		vim.notify("No test cases found in .cfhelper/", vim.log.levels.WARN)
	else
		vim.notify(
			string.format("Ran %d test(s): %d passed, %d failed", total, passed, total - passed),
			passed == total and vim.log.levels.INFO or vim.log.levels.WARN
		)
	end
end

return M
