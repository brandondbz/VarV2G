%use reference class as we will access the instance from many remote areas
%so a value class willl be untennable or at least annoying
classdef PowSim < handle

  properties
    cse;
    opt;
    pret;
    Busses;
  endproperties

  methods
    function obj=PowSim(src, ld)
      if exist('ld','var')==0
        %default to zero as the main use is with other load managers
        %however, can call with 1 for a simple run with basic loads.
        ld=0;
      endif
      obj.cse=loadcase(src);
      obj.opt=mpoption();
      %just to ensure it has ran once no problem
      %(so if low-level failure happens, we catch it and know where to go to fix
      obj.pret=runpf(obj.cse,obj.opt);
      obj.Busses={};
      for i = 1:eref.bus_count(obj.pret)
        obj.Busses{i}=Bus(obj, i);
        if ld==1
          obj.Busses{i}.BaseLoad();
        endif
      endfor
    endfunction

    function [bs,ct]=getBusses(obj)
      bs=obj.Busses;
      ct=length(obj.Busses)
    endfunction
    function b=getBus(obj, i)
      b=obj.Busses{i};
    endfunction
    function update(obj,i)
      %can add sys wide updates if needed.
      for a=obj.Busses
        a=a{1};
        a.Update(i);
      endfor
    endfunction
    function Run(obj,i)
      %make sure the load changes apply
      for bi = 1:length(obj.Busses)
        b=obj.Busses{bi};
        b.Update();
      endfor
      %tip: if we want to implement (e.g. line variability) do that here as well
      %run
      obj.pret=runpf(obj.cse,obj.opt);
    endfunction

  endmethods



endclassdef

