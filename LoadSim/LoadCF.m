classdef LoadCF < Load
  properties
  LoadCrv
  endproperties
  methods
  function obj=LoadCF(LC,BS)
    obj.LoadCrv=LC;
    X=1*deltaT;
    s=obj.LoadCrv.Interpolate(X);
    obj.Pd=obj.LBus=BS;
  endfunction
  function UpdateF(obj, i)
    global deltaT
    X=i*deltaT;
    s=obj.LoadCrv.Interpolate(X);
    obj.Pd=obj.LBus.PB*s;
    obj.Qd=obj.LBus.QB*s;
  endfunction
  endmethods

endclassdef

