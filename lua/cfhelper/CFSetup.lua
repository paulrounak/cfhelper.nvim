local M = {}

-- Unescape HTML entities
local function decode_html(s)
	return s:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&"):gsub("&quot;", '"'):gsub("&#39;", "'")
end

-- Extract text from <div> blocks or fallback to plain <pre> content
local function extract_input(pre)
	local lines = {}
	for line in pre:gmatch("<div[^>]*>(.-)</div>") do
		table.insert(lines, decode_html(line))
	end
	if #lines == 0 then
		return decode_html(pre)
	end
	return table.concat(lines, "\n")
end

local function extract_output(pre)
	return decode_html(pre):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.setup(url)
	local file_dir = vim.fn.expand("%:p:h")
	local helper_dir = file_dir .. "/.cfhelper"
	vim.fn.mkdir(helper_dir, "p")

	local html_path = helper_dir .. "/problem.html"
	local curl_cmd =
		string.format("curl -sL --compressed -A 'Mozilla/5.0' -e 'https://codeforces.com' '%s' -o '%s'", url, html_path)
	os.execute(curl_cmd)

	local f = io.open(html_path, "r")
	if not f then
		vim.notify("Couldn't read problem.html", vim.log.levels.ERROR)
		return
	end
	local html = f:read("*a")
	f:close()

	if not html or html == "" then
		vim.notify("Downloaded HTML is empty or invalid.", vim.log.levels.ERROR)
		return
	end

	local pre_blocks = {}
	for pre in html:gmatch("<pre>(.-)</pre>") do
		table.insert(pre_blocks, pre)
	end

	if #pre_blocks < 2 then
		vim.notify("No sample test cases found in problem.html", vim.log.levels.ERROR)
		return
	end

	local count = 0
	for i = 1, #pre_blocks - 1, 2 do
		local input = extract_input(pre_blocks[i])
		local output = extract_output(pre_blocks[i + 1])

		local function write(name, content)
			local wf = io.open(helper_dir .. "/" .. name, "w")
			if wf then
				wf:write(content)
				wf:close()
			end
		end

		write(string.format("input%d.txt", count + 1), input)
		write(string.format("output%d.txt", count + 1), output)

		count = count + 1
	end

	vim.notify(string.format("Downloaded %d sample test case(s) to .cfhelper/", count), vim.log.levels.INFO)
end

return M
