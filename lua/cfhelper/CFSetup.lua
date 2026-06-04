local M = {}
local ui = require("cfhelper.CFSetup_ui")

local function decode_html(text)
    return text
        :gsub("&lt;", "<")
        :gsub("&gt;", ">")
        :gsub("&amp;", "&")
        :gsub("&nbsp;", " ")
end

local function extract_sample_block(pre_block)
    local text = pre_block

    text = text:gsub("<br%s*/?>", "\n")

    -- Convert adjacent divs into line breaks
    text = text:gsub("</div>%s*<div[^>]*>", "\n")

    -- Remove all remaining tags
    text = text:gsub("<[^>]+>", "")

    text = decode_html(text)

    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")

    return text
end

local function extract_samples(html)
    local tests = {}

    local sample_start = html:find('<div class="sample%-test">')

    if not sample_start then
        return tests
    end

    local sample_html = html:sub(sample_start)

    local pre_blocks = {}

    local pos = 1
    while true do
        local s, e = sample_html:find("<pre[^>]*>", pos)

        if not s then
            break
        end

        local close = sample_html:find("</pre>", e + 1, true)

        if not close then
            break
        end

        table.insert(pre_blocks, sample_html:sub(e + 1, close - 1))

        pos = close + 6
    end

    for i = 1, #pre_blocks - 1, 2 do
        table.insert(tests, {
            input = extract_sample_block(pre_blocks[i]),
            output = extract_sample_block(pre_blocks[i + 1]),
        })
    end

    return tests
end

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

    local tests = extract_samples(html)

    if #tests == 0 then
        print("Failed to parse samples")
        return
    end

    for i, test in ipairs(tests) do
        local input_path = string.format("%s/input%d.txt", helper_dir, i)
        local output_path = string.format("%s/output%d.txt", helper_dir, i)

        local in_file = io.open(input_path, "w")
        if in_file then
            in_file:write(test.input)
            in_file:close()
        end

        local out_file = io.open(output_path, "w")
        if out_file then
            out_file:write(test.output)
            out_file:close()
        end
    end

    print(string.format(
        "Wrote %d sample test case(s) to .cfhelper/",
        #tests
    ))
end

function M.setup()
    ui.prompt_url(fetch_and_parse)
end

return M
