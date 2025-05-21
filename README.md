# cfhelper.nvim

A lightweight Neovim plugin to simplify running and testing Codeforces problems locally.

This plugin automates the workflow of fetching sample test cases and checking your solution output against them.

## Features

**`:CFSetup <url>`**
Parses a Codeforces problem page and automatically creates `input.txt` and `output.txt` inside a `.cfhelper` directory beside your source file.

**`:CFRun`**
Compiles your current C++ file, runs it using the generated `input.txt`, and compares the result with `output.txt`. Prints `Passed` or `Failed` based on `diff`.

All generated files including `input.txt`, `output.txt`, `result.txt`, `problem.html`, and the compiled binary are stored in a `.cfhelper` directory located beside your source file. This keeps your workspace clean and organized.

## Supported Languages
- C++

## Installation

**Using lazy.nvim:**

```lua
{
  "paulrounak/cfhelper.nvim",
  config = function()
    require("cfhelper")
  end,
}
```

**Using packer.nvim:**

```lua
use({
  "paulrounak/cfhelper.nvim",
  config = function()
    require("cfhelper")
  end,
})
```

## Requirements

* Neovim 0.11
* Linux (tested)
* g++ installed and available in your system path
* Internet access for fetching problem data via `:CFSetup`

## Usage

1. Open a C++ file in Neovim.
2. Run `:CFSetup <codeforces_problem_url>`
   Example: `:CFSetup https://codeforces.com/problemset/problem/4/A`
3. Write the solution to the problem in the C++ file.
4. Run `:CFRun` to compile and test against the sample input/output.

All temporary and generated files will be stored in a `.cfhelper` folder beside your code file.

## Why This Plugin

When solving Codeforces problems, the manual process usually looks like this:

1. Compile your code
2. Run the binary
3. Paste the input manually
4. Compare the output with the sample output manually

This plugin automates that entire process, reducing time and human error.

## Future Plans

* Support for multiple test cases
* Floating UI for test results
* Diagnostic display for mismatches
* Add multi-language support
