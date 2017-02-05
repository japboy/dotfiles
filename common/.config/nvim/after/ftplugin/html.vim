if findfile('.htmlhintrc', '.;') != ''
  let b:syntastic_checkers = ['htmlhint']
  let b:syntastic_html_htmlhint_exec = '`npm bin`/htmlhint'
endif
