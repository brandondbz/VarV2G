classdef EVs < Load
    properties(Static)
      TypeDC=1;
      TypeAC=0;
    endproperties
  properties
    %TODO:
    %important is to load charging and AEV from matching curves
    %we will only be doin 1 2 or 3 shift

    Charging;
    AEV=[];
    name="EVs";
  endproperties
  methods
    function obj=EVs(charging)
        cfg=Config.Inst();
        obj.Chargeing=charging;

    endfunction
    function Q=MaxQ(obj,i)
      Q=sqrt(Batt.SMax^2-obj.Pd^2);
    endfunction
    function UpdateQ(obj,i)
      %so we can chain in the branch cases
      if isobject(obj.Controller)
        %control the Q in this case.
        obj.Qd=obj.Controller.Update(i);
      else
        obj.Qd=0;
      endif
    endfunction

    function UpdateF(obj,i)
      %created so that anytime 'update' is called on object, it will call 'UpdateF' if available
      %to alow for mix of static and reactive loads
      if i > length(AEV)
        obj.Pd=0;
        obj.Qd=0;
        return;
      endif
      if AEV(i)==0
        obj.Pd=0;
        %if the cars away, it was driven.
        %a future work could be to simulate the cars activity better.
        obj.Batt.Discharge();
        if obj.CType==EV.TypeAC
          obj.Qd=0;
          return;
        elseif obj.CType==EV.TypeDC
          obj.UpdateQ(i);
          return;
        endif
      else
        obj.Pd=Batt.Charge();
      endif
    endfunction

  endmethods

endclassdef

