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
    local lines = {}

    -- Modern Codeforces format
    for line in pre_block:gmatch('<div class="test%-example%-line[^"]*">(.-)</div>') do
        line = decode_html(line)
            :gsub("^%s+", "")
            :gsub("%s+$", "")

        table.insert(lines, line)
    end

    if #lines > 0 then
        return table.concat(lines, "\n")
    end

    -- Fallback for older CF pages
    return decode_html(
        pre_block
            :gsub("<br%s*/?>", "\n")
            :gsub("<.->", "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")
    )
end

local function extract_samples(html)
    local tests = {}

    local sample_section =
        html:match('<div class="sample%-tests">(.-)</div><div class="note">')

    if not sample_section then
        sample_section =
            html:match('<div class="sample%-tests">(.-)</div>%s*</div>%s*<p>')
    end

    if not sample_section then
        return tests
    end

    local pre_blocks = {}

    for pre in sample_section:gmatch("<pre>(.-)</pre>") do
        table.insert(pre_blocks, pre)
    end

    for i = 1, #pre_blocks, 2 do
        local input_pre = pre_blocks[i]
        local output_pre = pre_blocks[i + 1]

        if input_pre and output_pre then
            table.insert(tests, {
                input = extract_sample_block(input_pre),
                output = extract_sample_block(output_pre),
            })
        end
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

-- UI entry
function M.setup()
    ui.prompt_url(fetch_and_parse)
end

return M
