" Miniwords
noremap <silent> <plug>(polyword-miniword-w) <cmd>lua require("polyword").miniword("w")<cr>
noremap <silent> <plug>(polyword-miniword-b) <cmd>lua require("polyword").miniword("b")<cr>
noremap <silent> <plug>(polyword-miniword-e) <cmd>lua require("polyword").miniword("e")<cr>
noremap <silent> <plug>(polyword-miniword-ge) <cmd>lua require("polyword").miniword("ge")<cr>
onoremap <silent> <plug>(polyword-miniword-e) v<cmd>lua require("polyword").miniword("e")<cr>
onoremap <silent> <plug>(polyword-miniword-ge) v<cmd>lua require("polyword").miniword("ge")<cr>

onoremap <silent> <plug>(polyword-miniword-iw) <cmd>lua require("polyword").miniword("iw")<cr>
onoremap <silent> <plug>(polyword-miniword-aw) <cmd>lua require("polyword").miniword("aw")<cr>
xnoremap <silent> <plug>(polyword-miniword-iw) v<cmd>lua require("polyword").miniword("iw")<cr>
xnoremap <silent> <plug>(polyword-miniword-aw) v<cmd>lua require("polyword").miniword("aw")<cr>
" Megawords
noremap <silent> <plug>(polyword-megaword-w) <cmd>lua require("polyword").megaword("w")<cr>
noremap <silent> <plug>(polyword-megaword-b) <cmd>lua require("polyword").megaword("b")<cr>
noremap <silent> <plug>(polyword-megaword-e) <cmd>lua require("polyword").megaword("e")<cr>
noremap <silent> <plug>(polyword-megaword-ge) <cmd>lua require("polyword").megaword("ge")<cr>

onoremap <silent> <plug>(polyword-megaword-e) v<cmd>lua require("polyword").megaword("e")<cr>
onoremap <silent> <plug>(polyword-megaword-ge) v<cmd>lua require("polyword").megaword("ge")<cr>

onoremap <silent> <plug>(polyword-megaword-iw) <cmd>lua require("polyword").megaword("iw")<cr>
onoremap <silent> <plug>(polyword-megaword-aw) <cmd>lua require("polyword").megaword("aw")<cr>
xnoremap <silent> <plug>(polyword-megaword-iw) v<cmd>lua require("polyword").megaword("iw")<cr>
xnoremap <silent> <plug>(polyword-megaword-aw) v<cmd>lua require("polyword").megaword("aw")<cr>
" Transforms
noremap <silent> <plug>(polyword-transform-camel) <cmd>lua require("polyword").transform("camel")<cr>
noremap <silent> <plug>(polyword-transform-pascal) <cmd>lua require("polyword").transform("pascal")<cr>
noremap <silent> <plug>(polyword-transform-snake) <cmd>lua require("polyword").transform("snake")<cr>
noremap <silent> <plug>(polyword-transform-kebab) <cmd>lua require("polyword").transform("kebab")<cr>
noremap <silent> <plug>(polyword-transform-snake-upper) <cmd>lua require("polyword").transform("snake-upper")<cr>
noremap <silent> <plug>(polyword-transform-kebab-upper) <cmd>lua require("polyword").transform("kebab-upper")<cr>
