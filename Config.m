%general config file. Then other classes can just
%cfg=Config.Inst();
%cfg.pget("var",default)/cfg.pset("var",value)
classdef Config < handle
  methods(Static)
    function obj=Inst()
      persistent config = nan;
      if ~isobject(config)
        config=Config();
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
      json=jsonencode(obj.CFG, "PrettyPrint", true);
      Config.filewrite(fname,json);
    endfunction
    function O=pget(obj,prop,O)
      if isfield(obj.CFG,prop)
        O=getfield(obj.CFG,prop);
      else
        obj.pset(prop,O); %make sure default is set.
        %doing this will make it easier to edit the settings later.
      endif
      %since we just have same var as our 'default' and output_precision
      %unmodified means default, modified means it got something
    endfunction
    function B=pexist(obj, prop)
      B=isfield(obj.CFG,prop);
    endfunction
    function pset(obj,prop,O)
      obj.CFG=setfield(obj.CFG, prop, O);
    endfunction
  endmethods
endclassdef
