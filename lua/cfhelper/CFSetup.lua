local M = {}
local ui = require("cfhelper.CFSetup_ui")

-- Extract all sample <pre> blocks safely
local function extract_all_pre_blocks(html)
    local blocks = {}
    for block in html:gmatch("<pre[^>]*>(.-)</pre>") do
        table.insert(blocks, block)
    end
    return blocks
end


-- Convert CF sample block into clean text
local function extract_sample_block(pre_block)
    local lines = {}

    -- Extract from Codeforces <div class="test-example-line">
    for line in pre_block:gmatch("<div[^>]*>(.-)</div>") do
        line = line
            :gsub("<.->", "")     -- remove nested tags if any
            :gsub("&lt;", "<")
            :gsub("&gt;", ">")
            :gsub("&amp;", "&")
            :gsub("&nbsp;", " ")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

        if line ~= "" then
            table.insert(lines, line)
        end
    end

    -- If no div-based format found, fallback to raw pre text
    if #lines == 0 then
        local text = pre_block
            :gsub("<br%s*/?>", "\n")
            :gsub("<.->", "")
            :gsub("&lt;", "<")
            :gsub("&gt;", ">")
            :gsub("&amp;", "&")
            :gsub("&nbsp;", " ")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

        return text
    end

    return table.concat(lines, "\n")
end

-- Main fetch function
local function fetch_and_parse(url)
    local file_dir = vim.fn.expand("%:p:h")
    local helper_dir = file_dir .. "/.cfhelper"

    if vim.fn.isdirectory(helper_dir) == 1 then
        vim.fn.delete(helper_dir, "rf")
    end

    vim.fn.mkdir(helper_dir, "p")

    local html_path = helper_dir .. "/problem.html"

    local curl_cmd = string.format(
        "curl -sL --compressed -A 'Mozilla/5.0' -e 'https://codeforces.com' '%s' -o '%s'",
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
        print("Failed to parse samples")
        return
    end

    local test_count = math.floor(#pre_blocks / 2)

    for i = 1, test_count do
        local input_block = pre_blocks[i * 2 - 1]
        local output_block = pre_blocks[i * 2]

        local input_text = extract_sample_block(input_block)
        local output_text = extract_sample_block(output_block)

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

------------------------------------------------------------
-- UI entry
------------------------------------------------------------
function M.setup()
    ui.prompt_url(fetch_and_parse)
end

return M
