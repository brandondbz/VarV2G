%provides direct access to underlying but, keeps index.
%one should set values only using direct (bus_) method OR indirect (load_) methods
%onc can always get values using direct (bus_) methods
%can be value technically since id doesn't change and PSi is already handle
classdef Bus < handle
  properties
    id;
    PSi;
    Loads={};
    QB;
    PB;
    thev
  endproperties

  methods
    function AddLoad(obj,ld)
      %I don't know which is the more 'correct' looking
      %but both work, and I think leaving ld without being {ld} look better.
      %importantly, we add the load to Loads.
      %we use the 'Load' class both as a base class for EV connections and randomized loads
      %and as the main class for static loads
      obj.Loads{end+1}=ld;
      %Loads=[Loads, ld];
      ld.LBus=obj;
    endfunction

    function ret=GetLoads(obj,name)
      ret=[]; rct=0;
      for i=1:length(obj.Loads)
        if obj.Loads(i).name==name
          rct+=1;
          ret(rct)=obj.Loads(i);
        endif
      endfor
    endfunction

    function QL=EV_QLim(obj)
      QL=[inf,-inf];
      for i=1:length(obj.Loads)
        if obj.Loads(i).name==name
          ev=obj.Loads(i);
          QL(1)=min(QL(1), ev.MaxQ());
          QL(2)=max(QL(2), ev.MaxQ());
        endif
      endfor
    endfunction

    function BaseLoad(obj)
      ld=Load();
      ld.LBus=obj;
      ld.TakeBase();
      obj.Loads{length(obj.Loads)+1} = ld;
    endfunction

    function obj=Bus(PS, i);
      obj.id=i;
      obj.PSi=PS;
      obj.QB=eref.bus_Qd(PS.cse,i);
      obj.PB=eref.bus_Pd(PS.cse,i);
      %TODO: Have all params read from a global CFG class, so we can adjust easily
      obj.thev=Thev(3)
    endfunction

    function SI=GetSI(obj)
      %\begin{equation}SI_{th} = \frac{1}{\left| Z_{L} \right| - \left| Z_{th} \right|}\end{equation}
      Vth=obj.thev.Vth;
      Zth=obj.thev.Zth;
      IL=(obj.bus_Pd()/obj.bus_Vm())+j*(obj.bus_Qd()/obj.bus_Vm());
      Zl=(obj.bus_Vm)/IL; %V/I=Z
      if isnan(Zth)
        SI=nan;
        return;
      endif
      SI=1/(abs(Zth)-abs(Zl));
    endfunction

    function Update(obj,i)
      %update Thevenin first
      %for that, we need the load current
      I=(obj.bus_Pd()/obj.bus_Vm)+j*(obj.bus_Qd()/obj.bus_Vm);
      %then approx.
      obj.thev.Approx(obj.bus_Vm(), I)
      %then update other (as this updates Pd,Qd)
      if length(obj.Loads)==0
        return;
      endif
      Pd=0;
      Qd=0;
      for a = obj.Loads
        a=a{1};
        a.Update(i)
        Pd+=a.Pd;
        Qd+=a.Qd;
      endfor
      obj.bus_Pd(Pd);
      obj.bus_Qd(Qd);
    endfunction

    function type_=bus_type(obj)
      type_=eref.bus_type(obj.PSi.cse, obj.id);
    endfunction
    function Pd=bus_Pd(obj, Pd)
      #set/get pattern.
      if exist('Pd','var')
        obj.PSi.cse=eref.bus_Pd(obj.PSi.cse, obj.id, Pd);
      else
        Pd=eref.bus_Pd(obj.PSi.cse, obj.id);
      endif
    endfunction

    function PDW=bus_Pd_W(obj, PDW)
      Sbase = obj.PSi.cse.baseMVA * 1e6;              %% in VA
      if exist('PDW','var')
        obj.bus_Pd(PDW/Sbase);
      else
        PDW=obj.bus_Pd()*Sbase;
      endif
    endfunction

    function Qd=bus_Qd(obj, Qd)
      #set/get pattern.
      if exist('Qd','var')
        obj.PSi.cse=eref.bus_Qd(obj.PSi.cse, obj.id, Qd);
      else
        Qd=eref.bus_Qd(obj.PSi.cse, obj.id);
      endif
    endfunction

    function QDW=bus_Pd_W(obj, QDW)
      Sbase = obj.PSi.cse.baseMVA * 1e6;              %% in VA
      if exist('QDW','var')
        obj.bus_Qd(QDW/Sbase);
      else
        QDW=obj.bus_Qd()*Sbase;
      endif
    endfunction

    function Gs=bus_Gs(obj, Gs)
      #set/get pattern.
      if exist('Gs','var')
        obj.PSi.cse=eref.bus_Gs(obj.PSi.cse, obj.id, Gs);
      else
        Gs=eref.bus_Gs(obj.PSi.cse, obj.id);
      endif
    endfunction

    function Bs=bus_Bs(obj, Bs)
      #set/get pattern.
      if exist('Bs','var')
       obj.PSi.cse= eref.bus_Bs(obj.PSi.cse, obj.id, Bs);
      else
        Bs=eref.bus_Bs(obj.PSi.cse, obj.id);
      endif
    endfunction

    function Vm=bus_Vm(obj, Vm)
      i=8;
      #set/get pattern.
      if exist('Vm','var')
      obj.PSi.cse=  eref.bus_Vm(obj.PSi.cse, obj.id, Vm);
      else
        Vm=eref.bus_Vm(obj.PSi.cse, obj.id);
      endif
    endfunction

    function Va=bus_Va(obj, Va)
      i=9;
      #set/get pattern.
      if exist('Va','var')
       obj.PSi.cse= eref.bus_Va(obj.PSi.cse, obj.id, Va);
      else
        Va=eref.bus_Va(obj.PSi.cse, obj.id);
      endif
    endfunction

    function V=GetVVolt(obj)
      vm=obj.bus_Vm;
      vb=obj.bus_baseKV()*1000;
      V=vm*Vb;
    endfunction

    function KV=bus_baseKV(obj,KV)
      i=10;
      #set/get pattern.
      if exist('KV','var')
        obj.PSi.cse=eref.bus_baseKV(obj.PSi.cse, obj.id, KV);
      else
        KV=eref.bus_baseKV(obj.PSi.cse, obj.id);
      endif
    endfunction

    function Vmax=bus_Vmax(obj,Vmax)
      i=12;
      #set/get pattern.
      if exist('Vmax','var')
        obj.PSi.cse=eref.bus_Vmax(obj.PSi.cse, obj.id, Vmax);
      else
        Vmax=eref.bus_Vmax(obj.PSi.cse, obj.id);
      endif
    endfunction

    function Vmin=bus_Vmin(obj,Vmin)
      i=13;
      #set/get pattern.
      if exist('Vmin','var')
        obj.PSi.cse=eref.bus_Vmin(obj.PSi.cse, obj.id, Vmin);
      else
        Vmin=eref.bus_Vmin(obj.PSi.cse, obj.id);
      endif
    endfunction

  endmethods
  endclassdef
