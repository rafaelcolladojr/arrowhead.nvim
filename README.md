# arrowhead.nvim

:bow_and_arrow: arrowhead.nvim makes converting function definitions between fat arrow and standard notations a breeze.

<BR>

<div align="center">
<img width="400" src="https://github.com/rafaelcolladojr/arrowhead.nvim/assets/7101404/785cded9-afa4-4a9c-b43b-0c1e577b5b83"/>
</div>
    
<BR>

> [!NOTE]
> This plugin is experimental and has only been tested on Flutter/Dart code.
> 
> If you'd like this plugin to work for your preferred language, feel free to submit an issue.

<BR>
    
## Why does this exist?

As a Flutter developer, handling deeply nested class and function definitions is a regular experience. Regardless of language/framework, needing to convert an auto-generated fat arrow function into a standard, return statement function notation is a drag.
Manually finding where these definitions end to insert that semicolon and closing brace always proves annoying and tiring.
    
<BR>

Check out the gif above for a clear illustration of what this does!

<BR>

## Installation

Install like any other vim plugin.
Here are examples using some popular package managers:

### packer.nvim

```lua
use {
    'rafaelcolladojr/arrowhead.nvim',
    requires = { {'nvim-treesitter/nvim-treesitter'} }
    }
```

### lazy.nvim

```lua
{
    'rafaelcolladojr/arrowhead.nvim',
    dependencies = { 'nvim-treesitter' }
}
```

### vim-plug

```lua
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'rafaelcolladojr/arrowhead.nvim'
```

<BR>

## Usage

To swap the notation of the function/method under the cursor simply run:
```lua
:lua require('arrowhead').swap_notation()
```

#### Example

You can set it to a normal mode binding like:
```lua
vim.keymap.set('n', '<leader>ah', ':lua R("arrowhead").swap_notation()<CR>')
```

<BR>

## TODO

- [x] Basic conversion logic
- [ ] Ignore comments (https://github.com/rafaelcolladojr/arrowhead.nvim/issues/1)
- [ ] Popular language coverage
