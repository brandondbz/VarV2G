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
    minP=Config.Inst().pget("minP", PS.CalBusses(@(b)(b.bus_Pd*0.5)));
    maxP=Config.Inst().pget("maxP", PS.CalBusses(@(b)(b.bus_Pd*1.5)));

    EVB=PS.GetBussesEVs();
    obj.EVB=EVB;
    mmQ=PS.GetQLim(1);
    minQ=mmQ(1,:);
    maxQ=mmQ(2,:);

    minV=minV(:)';
    maxV=maxV(:)';
    minP=minP(:)';
    maxP=maxP(:)';
    obj.PSys=PS;
    obj.QL=QLearning( minV, minP, maxV, maxP, minQ,  maxQ);
  endfunction

  function PreUpdate(obj,i)

    %thankfully, if all is good the inner update loop here is fairly simple
    %1) Find Qmin, Qmax
    PSys=obj.PSys;
        JI=PSys.GetJI
    if ~isempty(JI)
      obj.JLast=1/(sum(JI));
    else
      printf("EmptyJI")
      obj.JLast=nan;
      endif
    mmQ=PSys.GetQLim(i);
    minQ=mmQ(1,:);
    maxQ=mmQ(2,:);
    %2) pack current state
    V=PSys.GetV();
    P=PSys.GetP();
    Q=PSys.GetQ();
    %3)call our QLearning methods
    [state,act,QA]=obj.QL.Act( V, P,Q, minQ, maxQ)
    obj.state=state;
    obj.Act=act;
    %4)apply the action to the EVs.
    %for simplicityies sake, use greedy leveraging
    EVs=PSys.GetLoads("EV");
    QAA=zeros(1,length(EVs));
    for bus=1:length(EVs)
      LEVs=EVs{bus};
      %since 3 state and below will always b 0 or +/-QMax
       if obj.QL.actionTable.k<=3
        Q=PSys.GetQ()(:)'+0.1*(QA(bus));
       else
        Q=QA(bus);
      endif
      QAA(bus)=Q;
      for j=1:length(LEVs)
          LE=LEVs{j};
          if Q<0
            LE.Qd=max(LE.MinQ(i),Q);
          elseif Q>0
            LS.Qd=min(LE.MaxQ(i),Q);
          else
            LS.Qd=0;
           endif
            Q-=LE.Qd;
      endfor
    endfor

    Record.Inst().RowAdd('QA',QAA);
  endfunction
  function PostUpdate(obj,i)
      PSys=obj.PSys;
    JI=PSys.GetJI
    if ~isempty(JI)
      obj.JNext=1/(sum(JI));
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
    obj.QL.updateQTable(obj.state, obj.Act,JR,V,P,Q);
  endfunction
endmethods


endclassdef

