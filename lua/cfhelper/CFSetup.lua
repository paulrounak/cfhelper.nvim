local M = {}
local ui = require("cfhelper.CFSetup_ui")

-- Extract each input line from <div ...>...</div> inside the first <pre>
local function extract_input_lines(pre_block)
	local lines = {}
	for line in pre_block:gmatch("<div[^>]->(.-)</div>") do
		line = line:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&")
		table.insert(lines, line)
	end
	return table.concat(lines, "\n")
end

-- Extract plain text output from the <pre> block
local function extract_output(pre_block)
	return pre_block:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&"):gsub("^%s+", ""):gsub("%s+$", "")
end

-- Extract all <pre>...</pre> blocks from the HTML
local function extract_all_pre_blocks(html)
	local pre_blocks = {}
	for block in html:gmatch("<pre>(.-)</pre>") do
		table.insert(pre_blocks, block)
	end
	return pre_blocks
end

local function fetch_and_parse(url)
	local file_dir = vim.fn.expand("%:p:h")
	local helper_dir = file_dir .. "/.cfhelper"

	-- Clean previous .cfhelper
	if vim.fn.isdirectory(helper_dir) == 1 then
		vim.fn.delete(helper_dir, "rf")
	end

	vim.fn.mkdir(helper_dir, "p")

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

	local pre_blocks = extract_all_pre_blocks(html)

	if #pre_blocks < 2 then
		print("Failed to parse sample input/output from problem.html")
		return
	end

	local test_count = math.floor(#pre_blocks / 2)
	for i = 1, test_count do
		local input_block = pre_blocks[i * 2 - 1]
		local output_block = pre_blocks[i * 2]

		local input_text = extract_input_lines(input_block)
		local output_text = extract_output(output_block)

		local input_path = string.format("%s/input%d.txt", helper_dir, i)
		local output_path = string.format("%s/output%d.txt", helper_dir, i)

		local in_file = io.open(input_path, "w")
		if in_file then
			in_file:write(input_text)
			in_file:close()
		end

		local out_file = io.open(output_path, "w")
		if out_file then
			out_file:write(output_text)
			out_file:close()
		end
	end

	print(string.format("Wrote %d sample test case(s) to .cfhelper/", test_count))
end

function M.setup()
	ui.prompt_url(fetch_and_parse)
end

return M
