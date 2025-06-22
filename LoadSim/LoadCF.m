classdef LoadCF < Load
  properties
    LoadCrv
    LCName
    name="duck";
    %LBus;
    %Pd;
    %Qd;
  endproperties
  methods
  function obj=LoadCF(LC,BS)
    deltaT=Config.Inst().pget("deltaT");
    obj.LoadCrv=LC.data;
    obj.LCName=LC.name;
    X=1*deltaT;
    s=obj.LoadCrv.Interpolate(X);
    obj.LBus=BS;
    obj.Pd=BS.PB*s;
    obj.Qd=BS.QB*s;
  endfunction
  function UpdateF(obj, i)
     deltaT=Config.Inst().pget("deltaT");
    X=i*deltaT;
    s=obj.LoadCrv.Interpolate(X);
    obj.Pd=obj.LBus.PB*s;
    obj.Qd=obj.LBus.QB*s;
  endfunction
  endmethods

endclassdef

