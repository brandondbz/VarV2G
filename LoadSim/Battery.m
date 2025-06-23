classdef Battery < handle
  properties
    Capacity;
    SOC;
    ChargeP;
    SMax;
    DriveDC;
  endproperties
  methods
    function obj=Battery(Cap, SOC,ChargeP, DriveDC)
      obj.Capacity=Cap;
      obj.SOC=SOC;
      if length(ChargeP)>1
        error(sprintf("Invalid range: %s\n",sprintf("%d, ",ChargeP)));
      endif
      obj.ChargeP=ChargeP;
      obj.DriveDC=DriveDC;
      obj.SMax=Config.Inst().pget('BattSMaxRel', 1.1)*ChargeP;
    endfunction
    function obj2=Copy(obj)
      obj2=Battery(obj.Capacity, obj.SOC, obj.ChargeP, obj.DriveDC);
    endfunction
    function Discharge(obj)
        deltaT=Config.Inst().pget("deltaT");
       obj.SOC=max(obj.SOC-(obj.DriveDC/deltaT),0);
    endfunction
    function P=Charge(obj)
      deltaT=Config.Inst().pget("deltaT");
      if obj.SOC<obj.Capacity
        obj.SOC += obj.ChargeP*deltaT;
        P=obj.ChargeP
      else
        P=0;
      endif
    endfunction
  endmethods

endclassdef

