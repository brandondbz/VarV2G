classdef SysServer < handle
properties
  QL;
  PSys;
  EVB;
  state=[];
  Act=[];
  JLast=nan;
  JNext=nan;
endproperties
methods (Static)
  function ret= maxEV(EVB)
    ret=zeros(1,length(EVB));
    for i=1:length(EVB)
      EVS=EVB{i};
      Qx=0;
      for j=1:length(EVS)
        Qx+=EVS(j).MaxQ;
      endfor
      ret(i)=Qx;
    endfor
  endfunction
endmethods

methods
  function obj=SysServer(PS)
    %{
    must first init V, SI, Action
    %}
    minV=Config.Inst().pget("minV", PS.CalBusses(@(b)(b.bus_Vmin)));
    maxV=Config.Inst().pget("maxV", PS.CalBusses(@(b)(b.bus_Vmax)));
    dQ=Config.Inst().pget("dQ",0.02);
    EVB=PS.GetBussesEVs();
    obj.EVB=EVB;

    minV=minV(:)';
    maxV=maxV(:)';
    obj.PSys=PS;
    obj.QL=QLearning( minV,maxV, dQ);
  endfunction

  function PreUpdate(obj,i)

    %thankfully, if all is good the inner update loop here is fairly simple
    %1) Find Qmin, Qmax
    PSys=obj.PSys;
        JI=PSys.GetJI
    if ~isempty(JI)
      obj.JLast=(mean(JI));
    else
      printf("EmptyJI")
      obj.JLast=nan;
      endif

    %2) pack current state
    V=PSys.GetV();

    %3)call our QLearning methods
    [state,act]=obj.QL.Act( V)
    obj.state=state;
    obj.Act=act;
    Action=obj.QL.actions(:, act);
    %4)apply the action to the EVs.
    %for simplicityies sake, use greedy leveraging
    EVs=PSys.GetLoads("EV");
    if Action(1)==0
          Record.Inst().RowAdd('QA',Action(:)');
      return;
    endif
    LEV=EVs{Action(1)}{1}
    LEV.Qd+=Action(2);
    if(LEV.Qd>LEV.MaxQ(i))
      LEV.Qd=LEV.MaxQ(i);
    endif
  if LEV.Qd<LEV.MinQ(i)
    LEV.Qd=LEV.MinQ(i);
  endif

    Record.Inst().RowAdd('QA',Action(:)');
  endfunction
  function PostUpdate(obj,i)
      PSys=obj.PSys;
      %TODO: Update the J to be just the voltage
      %seems that there is a feedback issue currently as it went wrong way.
      %also set QMax (+ve) at 0
      %also set the QMax constant.
    JI=PSys.GetJI
    if ~isempty(JI)
      obj.JNext=(mean(JI));
    else
      printf("EmptyJI")
      obj.JNext=nan;
    endif
    JR=obj.JLast-obj.JNext
        V=PSys.GetV();
         P=PSys.GetP();
        Q=PSys.GetQ();
        if(isnan(JR) || isinf(JR))
          obj.JLast
          obj.JNext
            printf("Warning: NAN for JR");
            obj.JNext
            obj.JLast
            return;
          endif

    %now update QTable last.
    obj.QL.updateQTable(obj.state, obj.Act,JR);
  endfunction
endmethods


endclassdef

