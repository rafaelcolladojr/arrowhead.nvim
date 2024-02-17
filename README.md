# arrowhead.nvim

arrowhead.nvim makes converting function definitions between fat arrow (=>) and standard ((){}) a breeze.

<div align="center">
    
<img width="600" src="https://user-images.githubusercontent.com/7101404/231954108-f0a763d9-b51a-45b0-979b-d44ec29e9cbd.gif">
    
</div>
    
<BR>

## Warning

This plugin is experimental and has only been tested on Dart (and similar languages) code.
If you'd like this to work in your preferred language, feel free to submit a feature request. Or better yet: submit a pull request.
    
## Why does this exist?

As a Flutter developer, handling deeply nested function definitions is a regular experience. Regardless of language/framework, needing to convert an auto-generated fat arrow function into a standard, return statement function is a drag.
Manually finding where these definitions end to insert that semicolon and closing brace always proves annoying and tiring.
    
<BR>

Check out the gif above for a clear illustration of what this does!

<BR>

## Installation

Install like any other vim plugin.
Here are examples using some popular package managers:

<details>
<summary>packer.nvim</summary>

```lua
use 'rafaelcolladojr/arrowhead.nvim'
```
</details>

<details>
<summary>lazy.nvim</summary>

```lua
{
    'rafaelcolladojr/arrowhead.nvim'
}
```
</details>

<details>
<summary>vim-plug</summary>
### vim-plug 

```lua
Plug 'rafaelcolladojr/arrowhead.nvim'
```
</details>

<BR>

## Usage

Placeholder text

<BR>

## TODO

- [x] Basic conversion logic
- [ ] Ignore comments
- [ ] Popular language coverage
