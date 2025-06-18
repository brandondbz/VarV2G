%meant to extend thic class as needed
%the base is only good for static loads
classdef Load < handle
    properties
        Pd=0;
        Qd=0;
        %gets initialized externally
        LBus;
    endproperties
    methods
       function TakeBase(obj)
         obj.Pd=obj.LBus.PB;
         obj.Qd=obj.LBus.QB;
       endfunction
       function Update(obj,i)
         #i is for time i
         if(ismethod(obj,'UpdateF'))
            obj.UpdateF(i);
         endif

       endfunction
    endmethods

     methods(Static)
       function obj=StaticLoad(P,Q)
         obj=Load()
         obj.Pd=P;
         obj.Qd=Q;
       endfunction
     endmethods
endclassdef

