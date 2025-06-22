classdef Run < handle
  properties
    %place any values to be saved here.
    Loads;
  endproperties
  methods
    function obj=Run(type,cfg_fname)
      ld=0;
      if exist(cfg_fname,"file")
        ld=1;
        Config.Inst().Load(cfg_fname);
      endif
      _Init;
      cfg=Config.Inst();
      obj.Loads=LoadEnumeration();
        if ld%load the saved config
          obj.UpdateProperties(obj.Loads, cfg.pget("LoadEnum", struct()));
        endif
      if type== -1
        %just get initialized
        cfg.pget("runs",1);
        %just get the cfg created
        PS=PowSim(); %use the value from config
        sys=SysServer(PS);
        p=obj.ExtractProperties(obj.Loads);
        cfg.pset("LoadEnum",p);
        cfg.Save(cfg_fname);
      endif
      switch type
        case 0
          obj.RunBase()
         case 1
          obj.RunEvNoSys();
        case 2
          obj.RunEvSys();
      endswitch
      diary off;
    endfunction
    function RunBase(obj)
      cfg=Config.Inst();
      %no EVs at all
      imax=round(24/cfg.pget("deltaT",0.1));
      %run n times.
      for j=1:cfg.pget("runs",1);

        PS=PowSim();
        obj.Loads.SetupLoads(PS,1);
        for i=1:imax
          PS.Update(i);
          PS.Run();
        endfor
      endfor
    endfunction
    function RunEvNoSys(obj)
      cfg=Config.Inst();
      %no EVs at all
      imax=round(24/cfg.pget("deltaT",0.1));
      %run n times.
      for j=1:cfg.pget("runs",1);
        PS=PowSim();
        obj.Loads.SetupLoads(PS);
          for i=1:imax
            PS.Update(i);
            PS.Run();
          endfor
      endfor
    endfunction
    function RunEvSys(obj)
      cfg=Config.Inst();
      %no EVs at all
      imax=round(24/cfg.pget("deltaT",0.1));
      %run n times.
      for j=1:cfg.pget("runs",1);
        PS=PowSim();
        SS=SysServer(PS);
        obj.Loads.SetupLoads(PS);
          for i=1:imax
            PS.Update(i);
            PS.Run();
            SS.Update(i);
          endfor
      endfor
    endfunction
  endmethods


  methods(Static)
  %local functions that can save or update from the Config params.
  function s = ExtractProperties(obj)
    % Ensure handle class
    if ~isa(obj, 'handle')
      error('Input must be a handle class object');
    endif

    props = properties(obj);
    s = struct();

    for i = 1:numel(props)
      propName = props{i};
      if strncmp(propName, 'p_', 2)
        s.(propName) = obj.(propName);
      endif
    endfor
  endfunction
  function  UpdateProperties(obj, s)
    if ~isa(obj, 'handle')
      error('First input must be a handle class object');
    endif

    if ~isstruct(s)
      error('Second input must be a structure');
    endif

    props = properties(obj);

    for i = 1:numel(props)
      propName = props{i};
      if strncmp(propName, 'p_', 2) && isfield(s, propName)
        obj.(propName) = s.(propName);
      endif
    endfor
  endfunction
endmethods
endclassdef

