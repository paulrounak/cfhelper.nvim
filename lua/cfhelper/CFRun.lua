local M = {}

local function ensure_trailing_newline(file)
	local f = io.open(file, "r+")
	if not f then
		return
	end
	local content = f:read("*a")
	if not content:match("\n$") then
		f:write("\n")
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
			print("Compilation failed. See .cfhelper/compile_error.txt")
		else
			print("Compilation failed and couldn't write error file.")
		end
		return
	end

	-- Detect number of test cases
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

		ensure_trailing_newline(output_file)
		ensure_trailing_newline(result_file)

		local diff_cmd = string.format("diff -q %s %s", output_file, result_file)
		vim.fn.system(diff_cmd)

		if vim.v.shell_error == 0 then
			print(string.format("Test case #%d: Passed", i))
		else
			print(string.format("Test case #%d: Failed", i))
		end

		i = i + 1
	end

	if i == 1 then
		print("No test cases found.")
	end
end

return M
