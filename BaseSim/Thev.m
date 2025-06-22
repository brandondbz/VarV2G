%Thevenin Approximation class.
classdef Thev < handle
  properties
    V=[];
    I=[];
    %nan until found.
    Vth=nan;
    Zth=nan;
    ct;
    bs=0;
  endproperties
  methods
    %V_1=V_th-I_tZ_th
    %assume: V_th, Z_th is (approximately) constant over a window
    %then we only need multiple V,I measures over time.
    %y=[V_1(1), V_1(2)...V_1(n)]';
    %H=[1 -I(1); 1 -I(2);...;1 -I(n)];
    function obj=Thev(ct)
      obj.ct=ct;
    endfunction
    function [Vth, Zth]=Approx(obj,V,I)
      return;
      if obj.bs<obj.ct
        obj.bs+=1;
        obj.V(obj.bs)=V;
        obj.I(obj.bs)=I;
      else
        obj.V=circshift(obj.V, 1);
        obj.V(1)=V;
        obj.I=circshift(obj.I, 1);
        obj.I(1)=I;
        H=[ones(size(obj.I')) -(obj.I')];
        y=obj.V';
        x=(H'*H)\H'*y;
        obj.Vth=x(1);
        obj.Zth=x(2);
      endif
      Vth=obj.Vth;
      Zth=obj.Zth;
    endfunction
    endmethods
endclassdef

