%the local octave installation did not contain the function 'contains'
%so this was whipped up.
%will call this if exist('contains')==0
function c=__contains(str,pat)
  pl=length(pat);
  ln=length(str)-pl+1;
  for i=1:ln
    if strcmp(pat, str(i:pl+i-1))
      c=true;
      return;
    endif
  endfor
  c=false;
endfunction

