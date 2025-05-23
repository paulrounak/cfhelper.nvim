<p align="center">
  <img width="128" height="128" alt="Logo" src="https://github.com/paulrounak/cfhelper.nvim/blob/main/assets/logo.png" />
</p>

<h1 align="center">cfhelper.nvim</h1>

<p align="center">
    <img alt="Latest release" src="https://img.shields.io/github/v/release/paulrounak/cfhelper.nvim?style=for-the-badge&logo=neovim&color=93c5fd&labelColor=1e293b" />
    <img alt="License" src="https://img.shields.io/github/license/paulrounak/cfhelper.nvim?style=for-the-badge&logo=open-source-initiative&color=fda4af&labelColor=1e293b" />
    <img alt="Stars" src="https://img.shields.io/github/stars/paulrounak/cfhelper.nvim?style=for-the-badge&logo=github&color=ddd6fe&labelColor=1e293b" />
</p>

<p align="center">
  A lightweight Neovim plugin to simplify running and testing Codeforces problems locally.  
  Automate your workflow and keep your workspace clean and organized.
</p>


> [!Note]  
>  Unlike many alternatives, cfhelper.nvim does not depend on browser extensions like Competitive Companion.


## Features

- **`:CFSetup`**  
  > Launches a window where you need to paste your codeforces URL and hit \<Return> in normal mode. \<Esc> in normal mode to cancel.
  
  Parses a Codeforces problem page and creates the following files inside a `.cfhelper` directory:
  - `input.txt` (sample input)
  - `output.txt` (expected output)
  - `problem.html` (problem statement)
  - All stored beside your source file.

- **`:CFRun`**  
  Compiles your current C++ file, runs it with `input.txt`, and compares the output with `output.txt`.  
  The result is printed and stored in `result.txt`.

> [!Note]  
>  All generated files including the compiled binary are saved inside `.cfhelper/` beside your source file, keeping your workspace clean.


## Why This Plugin

The typical process for testing Codeforces problems manually is:

1. Compile your code
2. Run the binary
3. Paste the sample input
4. Compare output with the expected output manually

`cfhelper.nvim` automates all of these steps within Neovim, allowing you to focus on writing correct and efficient code.



## Supported Languages

- C++


## Installation

### Using lazy.nvim

```lua
{
  "paulrounak/cfhelper.nvim",
  config = function()
    require("cfhelper")
  end,
}
```

### Using packer.nvim

```lua
use({
  "paulrounak/cfhelper.nvim",
  config = function()
    require("cfhelper")
  end,
})
```



## Requirements

- Neovim `>= 0.11`
- Linux (tested only on Linux)
- `g++` installed and available in your system path
- Internet access for fetching problem data



## Usage

1. Open a C++ file in Neovim.
2. Run the setup command with a Codeforces problem URL. For example: <br>

   ```
   :CFSetup https://codeforces.com/contest/2096/problem/B
   ```
3. Write your solution in the current file.
4. Run the test:
   ```vim
   :CFRun
   ```
5. Results will be printed in Neovim and saved to `.cfhelper/result.txt`.



## Future Plans

- Support for multiple sample test cases
- Floating UI to display test results
- Diagnostic highlighting for incorrect output lines
- Support for other languages (e.g., Python, Java)



## Contributing

Contributions are welcome. Please open issues for bugs or feature requests, or submit a pull request if you have improvements.

