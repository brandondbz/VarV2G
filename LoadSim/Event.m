classdef Event < Load
  properties
    run; %will be updated by the Run class to indicate which dat
    runT; %set at creation to set target day.
    bus=nan; %set at cration to set target bus. Not used after seeding loads.
    P; %Vector for power
    Q;
    k;
    runLength;
  endproperties
  methods

    function UpdateF(obj,i)
        if any(obj.run==obj.runT)
          if i>obj.runLength
            obj.Pd=0;
            obj.Qd=0;
            return;
          endif
          obj.Pd=obj.P(i);
          obj.Qd=obj.Q(i);
        else
          obj.Pd=0;
          obj.Qd=0;
        endif
    endfunction

    function obj=Event(ct)
      obj.runLength=ct;

      obj.P=zeros(1,obj.runLength);
      obj.Q=zeros(1,obj.runLength);

      obj.k=1:obj.runLength;
    endfunction

    function Rect(obj, SMax, start, stop)
      k=obj.k;
      obj.P(k>=start & k<=stop)=real(SMax)
      obj.Q(k>start & k<=stop)=imag(SMax)
    endfunction
    function Cust0(obj)
      k=obj.k;
      kmax=max(obj.k);
      k360=(3/6)*kmax;
      k400=(4/6)*kmax;
      Pmax=0.06;
      Pa=zeros(size(k));
      Pa(k>k360 & k<(k360+40+1))=[Pmax*0.005*(1:20) Pmax*0.005*(20:-1:1)];
      obj.P=Pa;
    endfunction
    function Cust(obj)
      k=obj.k;
      kmax=max(obj.k);
      kmin=(3/6)*kmax;
      kmax=(4/6)*kmax;
      Pmax=0.08;


      Pa=zeros(size(k));
      t=linspace(-1,1,(kmax-kmin));
      p=-t.^2+1;
      p*=Pmax;


     Pa(k>kmin & k<(kmin+length(p)+1))=p;
      obj.P=Pa;
    endfunction
    function RampRect(obj, SMax, start,rise, stop)
      k=obj.k;
      P=zeros(size(obj.k));
      Q=zeros(size(obj.k));

      P(k>=start & k<=(stop-rise))=real(SMax);
      Q(k>=start & k<=(stop-rise))=image(SMax);

      kern=ones(1,rise);
      P=conv(P,kern);
      Q=conv(Q,kern);

      obj.P(k>=start & k<=stop)+=P(k>=start & k<=stop);
      obj.Q(k>=start & k<=stop)+=Q(k>=start & k<=stop);

    endfunction

  endmethods
  methods(Static)
  function AddEvents(PS, EVS)
    if isempty(EVS)
      return;
    endif
    BSMax=PS.GetBussesCt();
    BSMin=2; %avoid slack bus
    %NOTE: while software will accept slack bus anywehre,
    %this project expects slack only at bus 1.
    for i=1:length(EVS)
      EVT=EVS{i};
      if ~isnan(EVT.bus)
        PS.GetBus(EVT.bus).AddLoad(EVT);
      else
        bus=randi(BSMax-BSMin)+BSMin;
        PS.GetBus(bus).AddLoad(EVT);
      endif
    endfor
  endfunction
  endmethods
 endclassdef
