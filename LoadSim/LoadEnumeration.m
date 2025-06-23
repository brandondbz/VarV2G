%goal is to add loads accordingly.
classdef LoadEnumeration<handle
  properties
    %config params
    %AEV
    Schedules={}
    duckLoads={};
    %charger
    %class1, 2, 3
    chargeType=[1,2,3];
    chargeAC=0;
    chargeDC=1;
    p_chargeIfr=[0,0,1];
    p_chargeMin=[0.05] ;%, 12000, 20000];
    p_chargeMax=[0.05] ;%, 24000, 50000];
    p_chargeChance=[1, 0.05, 0]
    p_SMaxRel=1;
    %chances of have a second given you have afirst
    %flips the coin until fail
    p_chargeChain=[0.6,0.25,0];
    %battery
    p_EV_Batt_Sigma=10000;
    p_EV_Batt_mean=100000;
    p_EV_MaxEvs=30;
    p_EV_MinEvs=10;
    %driving  %kwh/mi * mi/h = kwh/h (e.g. kw)
    %https://ecocostsavings.com/average-electric-car-kwh-per-mile/#:~:text=The%20average%20electric%20car%20kWh%20per%20100%20miles,100%20miles%20and%200.346kWh%20to%20travel%201%20mile.
    %states EV use 0.345 kwh/mi
    %45 mi/h was picked as it is the average speed limit in the authors area,
    %with roads commonly 30, 45, 55, or 70mph, skewed more toward the lower limits in town
    %and 55 or 70 between home and town or vice-versa
    p_EV_DRate_mean=0.346*45
    %5mph SD
    p_EV_DRate_sigma=0.346*5
    %scale the unit randn to specified mean,var
    NRand=@(o,s,n,m)s*randn(n,m)+o;
    chargeCt=0; %keep track as we want.
    p_Seed=now;
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
    function SetupDuck(obj, bs)
        lc=obj.duckLoads{randi(length(obj.duckLoads))};
        Pd=bs.bus_Pd;
        Qd=bs.bus_Qd;

        #circle of life, LoadCF takes bus, while bus adds to loads for calculation purposes
        Ld=LoadCF(lc,bs)
        bs.AddLoad(Ld)
    endfunction
    function SetupEV(obj,bs)
          Trig=rand();
        if Trig<obj.p_chargeChance(1)
          i=randi(obj.p_EV_MaxEvs-obj.p_EV_MinEvs)+obj.p_EV_MinEvs;
            CRate=obj.RandRange(obj.p_chargeMin(1),obj.p_chargeMax(1)); % best to keep PU all the time now
            E=EV(CRate, obj.p_SMaxRel*(bs.bus_Pd^2+bs.bus_Qd^2)^0.5, obj.Schedules,i,bs);
            E.name
            bs.AddLoad(E)

          printf("Added %d\n", i);
          %kbhit();
        else
          printf("No Trigger%d>%d", Trig, obj.p_chargeChance);
        endif
    endfunction

    function LoadSet=SetupLoads(obj,PowS,mode)

      if exist('mode','var')==0
        mode=2;
      endif
      obj.chargeCt=0;
      Seeding.Seed(obj.p_Seed);
      LoadSet=struct();
      %get the busses first
      [bs,ct]=PowS.getBusses();
      %next we will apply the 'duckLoads'
      DL=obj.duckLoads{randi(length(obj.duckLoads))};


      for i=1:length(bs)
        obj.SetupDuck(bs{i});
        if mode>=1
          printf("Setup EVs");
            obj.SetupEV(bs{i});
         else
            printf("Skip EVs");
        endif
      endfor
      %TODO: 1) add a LoadCF for the load at each bus, using base P,Q
      %2)add EVs randomly, looping the busses.
      %For each bus generate 1 or more evs (first use 'p_chargeChance', 2+ use 'p_chargeChain'
      %3)add the large charger to a bus (TODO: Create a simple array of possible busses and pick randomly)
      %4)add all info into 'LoadSet' and save as json when done.
      %5) Work on V1 of the QMat.m
    endfunction



  endmethods
endclassdef

