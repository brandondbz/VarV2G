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
      if exist('src','var')==0
          cfg=Config.Inst();
          if cfg.pexist("PowSrc")
            src=cfg.pget("PowSrc");
          else
            error("src undefined. must either call as PowSim(src) or first set 'Config.Inst().pset('PowSrc', 'filename')' first.")
          endif
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

    function ct=GetBussesCt(obj)
      ct=length(obj.Busses)
    endfunction

    function cel=GetBussesEVs(obj)
      cel=obj.ExecBusses(@(bus)(bus{1}.GetLoads("EV")));
    endfunction

    function ret=GetQLim(obj)
      ret=zeros(2,length(obj.Busses));
      for i=1:length(ret)
        ret(:,i)=obj.Busses{i}.EV_QLim()';
      endfor
    endfunction

    function cel=ExecBusses(obj,fun)
      cel=arrayfun(fun, obj.Busses, "UniformOutput", false)
    endfunction

    function ar=CalBusses(obj,fun)
      ar=zeros(1,length(obj.Busses));
      for i=1:length(ar)
        ar(i)=fun(obj.Busses{i});
      endfor
    endfunction

    function [bs,ct]=getBusses(obj)
      bs=obj.Busses;
      ct=length(obj.Busses)
    endfunction
    %putting it together
    function J=GetJ(obj)
      error("NO J");
    endfunction
    %needed for J
    function V=GetV(obj)
        %in implementation, the V will be averaged from multiple sensors at the bus
        %including meters, EVs, etc. One can look at our previous paper on
        %improved Thevenin estimates to see how that works, for this paper the
        %focus is on implementation of the control strategy, so we will simulate
        #using the direct bus measurement.
        V=zeros(1,length(obj.Busses));
        for i=1:length(V)
          %that said, unless we made the unrealistica assumtion that all the meters
          %are PMU, we need to only take the magnitude of the voltage (no angle).
          V(i)=obj.Busses(i).bus_Vm;
        endfor
    endfunction
    %needed for J
    function SI=GetSI(obj)
      SI=zeros(1,length(obj.Busses));
        for i=1:length(V)
          %that said, unless we made the unrealistica assumtion that all the meters
          %are PMU, we need to only take the magnitude of the voltage (no angle).
          SI(i)=obj.Busses(i).GetSI;
        endfor
    endfunction
    function b=GetBus(obj, i)
      b=obj.Busses{i};
    endfunction
    function Update(obj,i)
      %can add sys wide updates if needed.
      for a=obj.Busses
        a=a{1};
        a.Update(i);
      endfor
    endfunction
    function Run(obj)
      %tip: if we want to implement (e.g. line variability) do that here as well
      %run
      obj.pret=runpf(obj.cse,obj.opt);

      obj.cse
    endfunction

  endmethods



endclassdef

