# jekyll.nvim

Neovim plugin to create jekyll posts. 

This is a work in progress.

## Installation

lazy.nvim

```
return {
    'kanedo/jekyll.nvim'
}
```

## Usage

Provides command `:JekyllPost` which will create a post file in `$(CWD)/_posts/<date>_title.md`
