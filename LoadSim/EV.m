classdef EV < Load

properties
  SMax;
  QMax=[];
  PCharge=[];
  name="EV";
endproperties
methods
  function obj=EV(PCharge, SMax, AEVs, N, BS)
    deltaT=Config.Inst().pget("deltaT");
    QMax=[];
    PCharges=[];
    obj.SMax=SMax;
    for i=1:N
      %Get AEV
      AEid=randi(length(AEVs))
      AEV=AEVs{AEid}.AEV(:)'

    %find when EV plugs back ing
      Pulse=([0 diff(AEV)]>1);
      cfg=Config.Inst().pget("LoadEnum")
      if(isfield(cfg, 'p_EV_Batt_mean'))
        BCap=cfg.p_EV_Batt_mean;
      else
        BCap=100000;
      endif
      BCap/=BS.BaseVA;
      CTime=floor(BCap/(PCharge/N)/deltaT);
      %power chargeing
      PCharges(i,:)=conv(Pulse,(PCharge/N)*(ones(1,CTime)))(1:length(AEV));

      QMaxR=sqrt(((SMax/N).^2)-(PCharges(i,:).^2));
      %finally, blanck time EV not available
      QMaxR(AEV==0)=0;
      QMax(i,:)=QMaxR;
      % [SMax/N N AEid]

    endfor
    %N=N
   QSum= sum(QMax,1);

    obj.PCharge=sum(PCharges,1);
    obj.QMax=sum(QMax,1);
    obj.SMax=SMax;

  endfunction
  function Q=MinQ(obj,i)
      Q=-obj.QMax(i);
  endfunction
  function Q=MaxQ(obj,i)
    Q=0; %obj.QMax(i);
  endfunction

  function UpdateF(obj,i)
    %created so that anytime 'update' is called on object, it will call 'UpdateF' if available
    %to alow for mix of static and reactive loads
    %since we pre-calced, nothhing here.
    %endif

     obj.Qd=min(max(obj.Qd,obj.MinQ(i)),obj.QMax(i));
     obj.Pd=obj.PCharge(i);
    endfunction

  function curve=Emit(obj,ii,dt)
    DT=Config.Inst().pget("deltaT");
    Config.Inst().pset("deltaT",dt);
    try
      o=zeros(size(ii));
      %extract charging curve
    for i=(ii(:)')
      obj.UpdateF(i);
      o=obj.Pd;
    endfor

  catch err
    % Error handling
    fprintf('Caught an error: %s\n', err.message);
  end_try_catch
  %restore
  Config.Inst().pset("deltaT",DT);
 endfunction

endmethods

endclassdef

