function printErr(err)

  printf("%s\n%s\n\n", err.message, err.identifier);
  for i=1:length(err.stack)
    printf("'%s' @ '%d' in '%s'\n",  err.stack(i).name, err.stack(i).line, err.stack(i).file)
  endfor
endfunction
