# arrowhead.nvim

arrowhead.nvim makes converting function definitions between fat arrow (=>) and standard ((){}) a breeze.
    
<BR>

## Warning

This plugin is experimental and has only been tested on Dart (and similar languages) code.
If you'd like this to work in your preferred language, feel free to submit a feature request. Or better yet: submit a pull request.

<BR>
    
## Why does this exist?

As a Flutter developer, handling deeply nested function definitions is a regular experience. Regardless of language/framework, needing to convert an auto-generated fat arrow function into a standard, return statement function is a drag.
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

Coming soon

<BR>

## TODO

- [x] Basic conversion logic
- [ ] Ignore comments
- [ ] Popular language coverage
