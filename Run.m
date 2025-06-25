classdef Run < handle
  properties
    %place any values to be saved here.
    Loads;
    EVSys
    EVNoSys
    cfg_fname
    EEvents={}
    ConSys=0;
    ConNoSys=0;
    Sys=[];
  endproperties
  methods
    function obj=Run(cfg_fname)
      obj.cfg_fname=cfg_fname
    endfunction
    function Save(obj)
      if isobject(obj.EVSys)
        obj.EVSys.Save("TEMP\\EVSys.json");
      endif
      if isobject(obj.EVNoSys)
        obj.EVNoSys.Save("TEMP\\EVNoSys.json");
      endif
    endfunction
    function Load(obj)
      if exist("TEMP\\EVSys.json","file")
        obj.EVSys=Record();
        obj.EVSys.Load("TEMP\\EVSys.json");
      endif
      if exist("TEMP\\EVNoSys.json","file")
        obj.EVNoSys=Record();
        obj.EVNoSys.Load("TEMP\\EVNoSys.json")
      endif
    endfunction
    function RunIt(obj, type)
      cfg_fname=obj.cfg_fname;
      ld=0;
      _Init;
      if exist(cfg_fname,"file")
        ld=1;
        printf("Loaded\n");
        Config.Inst().Load(cfg_fname);
        Config.Inst().print_struct_fields();
      else
        printf("File Not Found");
        kbhit();
      endif

      cfg=Config.Inst();
      obj.Loads=LoadEnumeration();
        if ld %load the saved config
          obj.UpdateProperties(obj.Loads, cfg.pget("LoadEnum", struct()));

        endif
      if type== -1
        %just get initialized
        cfg.pget("runs",1);
        %just get the cfg created
        PS=PowSim(); %use the value from config
        sys=SysServer(PS);
        PS.GetJI();
        p=obj.ExtractProperties(obj.Loads);
        thv=Thev(10);
        for i=1:10
          thv.Approx(rand(),rand());

        endfor
        cfg.pset("LoadEnum",p);
        cfg.Save(cfg_fname);
        return
      endif
      switch type
        case 0
          obj.RunBase()
         case 1
          obj.RunEvNoSys();
        case 2
          obj.RunEvSys();
        case 3
          obj.RunEvNoSys();
          obj.RunEvSys();


      endswitch
      diary off;
    endfunction

    function PlotCmp(R)
      figure;      b=3;      plot(R.EVNoSys.CFG.V(:,b));      hold on;      plot(R.EVSys.CFG.V(:,b));      plot(R.EVSys.CFG.P(:,b)*10);      plot([1 length(R.EVSys.CFG.P)],[0.95 0.95],":");
    endfunction

    function PlotIt(obj)
      cfg=Config.Inst();
      imax=round(24/cfg.pget("deltaT",0.1));
      figure(1);
      VNS=obj.EVNoSys.pget('V');
      S=(length(VNS)-imax);
      if S<=0
        S=1; %keep at least 1 index in case.
      endif

      E=length(VNS);

       plot((S:E)/cfg.pget("deltaT"),VNS(S:E,:))
       xlabel time(hr);
       ylabel V(p.u.)
       title(" Voltage (No Compensation)")
      figure(2);
      VS=obj.EVSys.pget("V");
      plot((S:E)/cfg.pget("deltaT"), VS(S:E,:))
      xlabel time(hr);
       ylabel V(p.u.)
       title(" Voltage (With Compensation)")
      figure(3);
            %just substract
            %Vd= (obj.EVSys.CFG.V- obj.EVNoSys.CFG.V;
            %as a percentage tells the story better.
            Vd= (obj.EVSys.CFG.V- obj.EVNoSys.CFG.V)./(1-obj.EVNoSys.CFG.V);
            plot((S:E)/cfg.pget("deltaT"),Vd(S:E,:))
                   xlabel time(hr);
       ylabel V(p.u.)
       title(" Delta Voltage % (with control - without control)")

    endfunction


    function RunBase(obj)
      cfg=Config.Inst();
      %no EVs at all
      imax=round(24/cfg.pget("deltaT",0.1));
      %run n times.
      for j=1:cfg.pget("runs",1);

        PS=PowSim();
        obj.Loads.SetupLoads(PS,0);
        for i=1:imax
          PS.Update(i);
          PS.Run();

                      %recording
            rec=Record.Inst();
            rec.RowAdd("V", PS.GetV());
            rec.RowAdd("P",PS.GetP());
            rec.RowAdd("Q",PS.GetQ());
            rec.RowAdd("Vth",PS.GetThevVLog());
            rec.RowAdd("Zth",PS.GetThevZLog());
            rec.RowAdd("JI",1/sum(PS.GetJI()));
            rec.RowAdd("Run",j);
        endfor
      endfor

            rec.Save("Log\\LastBRec.json");
    endfunction

    function RunEvNoSys(obj)
      cfg=Config.Inst();
      %no EVs at all
      imax=round(24/cfg.pget("deltaT",0.1));
      %run n times.
      if ~isobject(obj.ConNoSys)
        PS=PowSim();
        obj.Loads.SetupLoads(PS,2);
        obj.CreateEvents(imax);
       Event.AddEvents(PS,obj.EEvents);
        obj.ConNoSys=PS;
        else
          PS=obj.ConNoSys;
     endif

          rec=Record.Inst(1);
      for j=1:cfg.pget("runs",1);
          obj.UpdateEventsRun(j);
          for i=1:imax
            PS.Update(i);
            PS.Run();

                        %recording

            rec.RowAdd("V", PS.GetV());
            rec.RowAdd("P",PS.GetP());
            rec.RowAdd("Q",PS.GetQ());
            rec.RowAdd("Vth",PS.GetThevVLog());
            rec.RowAdd("Zth",PS.GetThevZLog());
            rec.RowAdd("JI",1/sum(PS.GetJI()));
            rec.RowAdd("Run",j);
          endfor
      endfor
            obj.EVNoSys=rec;
            rec.Save("Log\\LastNSRec.json");
    endfunction


    function RunEvSys(obj)
      cfg=Config.Inst();
      %no EVs at all
      imax=round(24/(cfg.pget("deltaT",0.1)));
      %run n times.
        if ~isobject(obj.ConSys)
          PS=PowSim();
          obj.Loads.SetupLoads(PS,2);
          obj.CreateEvents(imax);
          Event.AddEvents(PS,obj.EEvents);
          obj.ConSys=PS;
        else
          PS=obj.ConSys;
        endif
        if isempty(obj.Sys)
            SS=SysServer(PS);
            obj.Sys=SS;
         else
            SS=obj.Sys;
          endif

        rec=Record.Inst(1);

        for j=1:cfg.pget("runs",1);
         obj.UpdateEventsRun(j);
          for i=1:imax
            SS.PreUpdate(i);
            PS.Update(i);
            PS.Run();

            SS.PostUpdate(i);

            %recording

            rec.RowAdd("V", PS.GetV());
            rec.RowAdd("P",PS.GetP());
            rec.RowAdd("Q",PS.GetQ());
            rec.RowAdd("Vth",PS.GetThevVLog());
            rec.RowAdd("Zth",PS.GetThevZLog());
            rec.RowAdd("JI",1/sum(PS.GetJI()));
            QL=PS.GetQLim(i);
            rec.RowAdd("QMin",QL(1,:));
            rec.RowAdd("QMax",QL(2,:));
            rec.RowAdd("Run",j);
          endfor
          beep
      endfor

      ToPrettyJson(PS,'Log\LastPS.json');
      ToPrettyJson(SS,'Log\LastSS.json');
      Config.Inst().Save('Log\LastCfg.json');
      Record.Inst().Save('Log\LastRec.json');
      rec.Save("Log\\LastSRec.json");
      obj.EVSys=rec;
    endfunction

    function CreateEvents(obj, imax)
      if(~isempty(obj.EEvents))
        return;
      endif
      obj.EEvents={};
      EVT1=Event(imax);
      %EVT1.Rect(0.05+0.02j, 3*imax/6, 4*imax/6)
      EVT1.Cust();
      EVT1.bus=5;
      EVT1.runT=[ 2];
      obj.EEvents(end+1)=EVT1;
      %can add more as desired.
    endfunction

    function UpdateEventsRun(obj,rn)
      for i=1:length(obj.EEvents)
        obj.EEvents{i}.run=rn;
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

