classdef Battery < handle
  properties
    Capacity;
    SOC;
    ChargeP;
    DriveDC;
  endproperties
  methods
    function obj=Battery(Cap, SOC,ChargeP, DriveDC)
      obj.Capacity=Cap;
      obj.SOC=SOC;
      obj.ChargeP=ChargeP;
      obj.DriveDC=DriveDC;
    endfunction
    function obj2=Copy(obj)
      obj2=Battery(obj.Capacity, obj.SOC, obj.ChargeP, obj.DriveDC);
    endfunction
    function Discharge(obj)
       global deltaT
       obj.SOC=max(obj.SOC-(obj.DriveDC/deltaT),0);
    endfunction
    function P=Charge(obj)
      global deltaT
      if obj.SOC<obj.Capacity
        obj.SOC += obj.ChargeP*deltaT;
        P=obj.ChargeP
      else
        P=0;
      endif
    endfunction
  endmethods

endclassdef

