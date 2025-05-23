local M = {}

-- Extract each input line from <div ...>...</div> inside the first <pre>
local function extract_input_lines(pre_block)
	local lines = {}
	for line in pre_block:gmatch("<div[^>]->(.-)</div>") do
		line = line:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&")
		table.insert(lines, line)
	end
	return table.concat(lines, "\n")
end

-- Extract plain text output from the second <pre> block
local function extract_output(pre_block)
	return pre_block:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&"):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.setup(url)
	-- Get directory of current file
	local file_dir = vim.fn.expand("%:p:h")
	local helper_dir = file_dir .. "/.cfhelper"
	vim.fn.mkdir(helper_dir, "p")

	-- Download problem with browser headers to avoid robocheck...
	local html_path = helper_dir .. "/problem.html"
	local curl_cmd = string.format(
		"curl -sL --compressed -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0 Safari/537.36' -e 'https://codeforces.com' '%s' -o '%s'",
		url,
		html_path
	)
	os.execute(curl_cmd)

	local f = io.open(html_path, "r")
	if not f then
		print("Couldn't read problem.html")
		return
	end

	local html = f:read("*a")
	f:close()

	-- Extract first and second <pre> blocks
	local input_pre = html:match("<pre>(.-)</pre>")
	local after_input = html:match("<pre>.-</pre>(.+)")
	local output_pre = after_input and after_input:match("<pre>(.-)</pre>")

	if not input_pre or not output_pre then
		print("Failed to parse sample input/output from problem.html")
		return
	end

	local input_txt = extract_input_lines(input_pre)
	local output_txt = extract_output(output_pre)

	-- Write to files
	local function write(name, content)
		f = io.open(helper_dir .. "/" .. name, "w")
		if f then
			f:write(content)
			f:close()
		end
	end

	write("input.txt", input_txt)
	write("output.txt", output_txt)

	print("Sample input/output written to .cfhelper/")
end

return M
