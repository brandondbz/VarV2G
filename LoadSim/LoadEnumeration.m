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
    %chances of have a second given you have afirst
    %flips the coin until fail
    chargeChain=[0.6,0.25,0];
    %battery
    EV_Batt_Sigma=10000;
    EV_Batt_mean=100000;
    %scale the unit randn to specified mean,var
    NRand=@(o,s,n,m)s*randn(n,m)+o;
  endproperties


  methods
    function obj=LoadEnumeration()
      obj.duckLoads=LoadCurve.LoadSet("LoadSim\\Data","_duck.json");
      obj.Schedules=Schedule.LoadSet("LoadSim\\Data","_AEV.csv");
    endfunction

    function LoadSet=SetupLoads(obj,PowS)
      LoadSet=struct();
      %get the busses first
      [bs,ct]=obj.PowS.getBusses();
      %next we will apply the 'duckLoads'
      DL=obj.duckLoads{randi(length(obj.duckLoads))};
      LoadSet.duckVer=obj.name;

    endfunction

  endmethods
endclassdef

