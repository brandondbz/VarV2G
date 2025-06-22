classdef SysServer < handle
properties
  QL;
  PSys;
  EVB;
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
    minSI=Config.Inst().pget("minSI", zeros(1,PS.GetBussesCt()));
    maxSI=Config.Inst().pget("maxSI", ones(1,PS.GetBussesCt()));
    minV=Config.Inst().pget("minV", PS.CalBusses(@(b)(b.bus_Vmin)));
    maxV=Config.Inst().pget("maxV", PS.CalBusses(@(b)(b.bus_Vmax)));

    EVB=PS.GetBussesEVs();
    obj.EVB=EVB;
    mmQ=PS.GetQLim();
    minQ=mmQ(1,:);
    maxQ=mmQ(2,:);
    obj.PSys=PS;
    obj.QL=QLearning( minV, minSI, maxV, maxSI, minQ,  maxQ);
  endfunction
  function Update(obj,i)
    %thankfully, if all is good the inner update loop here is fairly simple
    %1) Find Qmin, Qmax
    QL=PSys.GetQLim();
    %2) pack current state
    V=PSys.GetV();
    SI=PSys.GetSI();
    %3)call our QLearning methods
    obj.QL.act( V, SI, minQ, maxQ)
  endfunction
endmethods


endclassdef

