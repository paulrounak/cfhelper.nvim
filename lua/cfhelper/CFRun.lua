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
	local cpp_file = vim.fn.expand("%:p") -- Full path to current file
	local file_dir = vim.fn.expand("%:p:h") -- Directory of the current file

	local helper_dir = file_dir .. "/.cfhelper"
	vim.fn.mkdir(helper_dir, "p")

	local exec = helper_dir .. "/CFResult.out"
	local compile_cmd = string.format("g++ -o %s %s", exec, cpp_file)
	local result = vim.fn.system(compile_cmd)

	if vim.v.shell_error ~= 0 then
		local error_path = helper_dir .. "/compile_error.txt"
		local f, err = io.open(error_path, "w")
		if f then
			f:write(result)
			f:close()
			print("Compilation failed. See .cfhelper/compile_error.txt")
		else
			print("Compilation failed and couldn't write error file:", err)
		end
		return
	end

	local input_path = helper_dir .. "/input.txt"
	local output_path = helper_dir .. "/output.txt"
	local result_path = helper_dir .. "/result.txt"

	local run_cmd = string.format("%s < %s > %s", exec, input_path, result_path)
	os.execute(run_cmd)

	ensure_trailing_newline(output_path)
	ensure_trailing_newline(result_path)

	vim.fn.system(string.format("diff -q %s %s", output_path, result_path))

	if vim.v.shell_error == 0 then
		print("Passed")
	else
		print("Failed")
	end
end

return M
