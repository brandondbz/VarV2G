%goal is to add loads accordingly.
classdef LoadEnumeration
  properties
    %config params
    %AEV
    Scedules={}
    duckLoads={};
    %charger
    %class1, 2, 3
    chargeType=[1,2,3];
    chargeAC=0;
    chargeDC=1;
    chargeIfr=[chargeAC,chargeAC,chargeDC];
    chargeMin=[2000, 12000, 20000];
    chargeMax=[4000, 24000, 50000];
    chargeChance=[0.5, 0.05, 0]
    %will fill for stats purposes
    chargeCt=[0,0,1]
    chargeBusses3=[]; %fill with candidate busses for the charge center.
    %chances of have a second given you have afirst
    %flips the coin until fail
    chargeChain=[0.6,0.25,0];
    %battery
    EV_Batt_Sigma=10000;
    EV_Batt_mean=100000;
    %driving  %kwh/mi * mi/h = kwh/h (e.g. kw)
    %https://ecocostsavings.com/average-electric-car-kwh-per-mile/#:~:text=The%20average%20electric%20car%20kWh%20per%20100%20miles,100%20miles%20and%200.346kWh%20to%20travel%201%20mile.
    %states EV use 0.345 kwh/mi
    %45 mi/h was picked as it is the average speed limit in the authors area,
    %with roads commonly 30, 45, 55, or 70mph, skewed more toward the lower limits in town
    %and 55 or 70 between home and town or vice-versa
    EV_DRate_mean=0.346*45
    %scale the unit randn to specified mean,var
    NRand=@(o,s,n,m)s*randn(n,m)+o;

    Seed=now;
  endproperties
  methods(Static)
  function r=RandRange(mn,mx)
    dr=mx-mn;
    r=mn+rand()*dr;
  endfunction
  endmethods
  methods

    function obj=LoadEnumeration()
      obj.duckLoads=LoadCurve.LoadSet("LoadSim\\Data","_duck.json");
      obj.Schedules=Schedule.LoadSet("LoadSim\\Data","_AEV.csv");
    endfunction
    function SetupDuck(obj, bs,lc)
        Pd=bs.bus_Pd;
        Qd=bs.bud_Qd;
        #circle of life, LoadCF takes bus, while bus adds to loads for calculation purposes
        Ld=LoadCF(lc,bs)
        bs.addLoad(Ld)
    endfunction
    function SetupEV(obj,bs)
          Trig=rand();
        if Trig>obj.chargeChance(2)
          i=1
          do
            AEV = obj.Schedules(randi(length(obj.Schedules))).AEV;
            BCap=obj.EV_Batt_mean+randn()*obj.EV_Batt_Sigma;
            CRate=obj.RandRange(obj.chargeMin,obj.chargeMax);
            Batt=Battery(BCap,Bcap,CRate,  )
            E=EV(Batt, obj.chargeIfr(2), AEV);
            bs.addLoad(E);
            i+=1;
          until rand()>chargeChain(2)^i %enable multiple if there is one
        elseif Trig>obj.chargeChance(1)
          i=1
          do
            i+=1
          until rand()>chargeChain(1)^i
        endif
    endfunction
    function SetupCfg(obj,cfg)
      %straightforward copy values for params
    endfunction
    function SetupLoads(obj,PowS,cfg)
      if exist('cfg','var')
         SetupCfg(cfg);
      endif

      obj.chargeCt(1)=0;
      obj.chargeCt(2)=0;

      Seeding.Seed(obj.Seed);
      LoadSet=struct();
      %get the busses first
      [bs,ct]=obj.PowS.getBusses();
      %next we will apply the 'duckLoads'
      DL=obj.duckLoads{randi(length(obj.duckLoads))};
      LoadSet.duckVer=obj.name;


      for i=1:length(bs)
        obj.SetupDuck(bs(i));
        obj.SetupEV(bs(i));
      endfor
      %TODO: 1) add a LoadCF for the load at each bus, using base P,Q
      %2)add EVs randomly, looping the busses.
      %For each bus generate 1 or more evs (first use 'chargechance', 2+ use 'chargechain'
      %3)add the large charger to a bus (TODO: Create a simple array of possible busses and pick randomly)
      %4)add all info into 'LoadSet' and save as json when done.
      %5) Work on V1 of the QMat.m
    endfunction



  endmethods
endclassdef

