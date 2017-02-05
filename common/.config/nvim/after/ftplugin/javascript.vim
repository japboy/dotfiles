if findfile('.eslintrc.js', '.;') != ''
  let b:syntastic_checkers = ['eslint']
  let b:syntastic_javascript_eslint_exec = '`npm bin`/eslint'
endif
