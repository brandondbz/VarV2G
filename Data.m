classdef Data < handle
  methods(Static)
    function obj=Inst()
      persistent data = nan;
      if ~isobject(data)
        data=Data();
      endif
      obj=config;
    endfunction
    function filewrite(filename, content)
      fid = fopen(filename, 'w');
      if fid == -1
        error('Unable to open file.');
      endif
      fprintf(fid, '%s', content);
      fclose(fid);
    endfunction
  endmethods

  properties
    CFG=struct();
  endproperties
  methods
    function Load(obj,fname)
      obj.CFG=jsondecode(fileread(fname));
    endfunction
    function Save(obj,fname)
      json=jsonencode(obj.CFG);
      Config.filewrite(fname,json);
    endfunction

  endmethods
endclassdef
