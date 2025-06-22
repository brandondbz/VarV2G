classdef eref
  properties (Constant)
    %   MATPOWER
    %   Copyright (c) 1996-2024, Power Systems Engineering Research Center (PSERC)
    %   by Ray Zimmerman, PSERC Cornell
    %
    %   These properties come from a file that is part of MATPOWER (idx_bus.m).
    %   Covered by the 3-clause BSD License (see LICENSE file for details).
    %   See https://matpower.org for more info.

    %% define bus types
    PQ      = 1;
    PV      = 2;
    REF     = 3;
    NONE    = 4;

    %% define the indices
    BUS_I       = 1;    %% bus number (1 to 29997)
    BUS_TYPE    = 2;    %% bus type (1 - PQ bus, 2 - PV bus, 3 - reference bus, 4 - isolated bus)
    PD          = 3;    %% Pd, real power demand (MW)
    QD          = 4;    %% Qd, reactive power demand (MVAr)
    GS          = 5;    %% Gs, shunt conductance (MW at V = 1.0 p.u.)
    BS          = 6;    %% Bs, shunt susceptance (MVAr at V = 1.0 p.u.)
    BUS_AREA    = 7;    %% area number, 1-100
    VM          = 8;    %% Vm, voltage magnitude (p.u.)
    VA          = 9;    %% Va, voltage angle (degrees)
    BASE_KV     = 10;   %% baseKV, base voltage (kV)
    ZONE        = 11;   %% zone, loss zone (1-999)
    VMAX        = 12;   %% maxVm, maximum voltage magnitude (p.u.)      (not in PTI format)
    VMIN        = 13;   %% minVm, minimum voltage magnitude (p.u.)      (not in PTI format)

    %% included in opf solution, not necessarily in input
    %% assume objective function has units, u
    LAM_P       = 14;   %% Lagrange multiplier on real power mismatch (u/MW)
    LAM_Q       = 15;   %% Lagrange multiplier on reactive power mismatch (u/MVAr)
    MU_VMAX     = 16;   %% Kuhn-Tucker multiplier on upper voltage limit (u/p.u.)
    MU_VMIN     = 17;   %% Kuhn-Tucker multiplier on lower voltage limit (u/p.u.)
  endproperties
  methods(Static)
      function i=branch_ct(mpc)
        %get the count
        i=size(mpc.branch, 1);
      endfunction
      function [f,t]=branch_conn(mpc,row)
        f=mpc.branch(row,1);
        t=mpc.branch(row,2);
      endfunction

      function Z=ToOhms(mpc,Z)
        Vbase = mpc.bus(1, BASE_KV) * 1e3;      %% in Volts
        Sbase = mpc.baseMVA * 1e6;              %% in VA
        Z=Vbase^2/SBase*Z;
      endfunction
      function Z=FromOhms(mpc,Z)
                Vbase = mpc.bus(1, BASE_KV) * 1e3;      %% in Volts
                Sbase = mpc.baseMVA * 1e6;              %% in VA
                Z=(SBase/(Vbase^2))*Z; %just the reverse of ToOhms
      endfunction
  %define wrappers for componets we may/will modify.
  %biggest are Pd,Qd esp. Qd but Pd can be useful in the estim case.
      function ix=bus_i(mpc, row)
        ix=mpc.bus(row,1);
      endfunction
      function ix=bus_imax(mpc)
        ix=max(mpc.bus(:,1));
      endfunction
      function ct=bus_count(mpc)
        ct=size(mpc.bus,1);
      endfunction
      function type_=bus_type(mpc,row)
        type_=mpc.bus(row,2);
      endfunction
      function Pd=bus_Pd(mpc,row,Pd)
        #set/get pattern.
        if exist('Pd','var')
          mpc.bus(row,3)=Pd;
          Pd=mpc;
          else
          Pd=mpc.bus(row,3);
        endif
      endfunction
      function Qd=bus_Qd(mpc,row,Qd)
        #set/get pattern.
        if exist('Qd','var')
          mpc.bus(row,4)=Qd;
          Qd=mpc;
          else
          Qd=mpc.bus(row,4);
        endif
      endfunction
      function Gs=bus_Gs(mpc,row,Gs)
        #set/get pattern.
        if exist('Gs','var')
          mpc.bus(row,5)=Gs;
          Gs=mpc;
          else
          Gs=mpc.bus(row,5);
        endif
      endfunction
      function Bs=bus_Bs(mpc,row,Bs)
        #set/get pattern.
        if exist('Bs','var')
          mpc.bus(row,6)=Bs;
          Bs=mpc;
          else
          Bs=mpc.bus(row,6);
        endif
      endfunction
      function Vm=bus_Vm(mpc,row,Vm)
        i=8;
        #set/get pattern.
        if exist('Vm','var')
          mpc.bus(row,i)=Vm;
          Vm=mpc;
          else
          Vm=mpc.bus(row,i);
        endif
      endfunction
      function Va=bus_Va(mpc,row,Va)
        i=9;
        #set/get pattern.
        if exist('Va','var')
          mpc.bus(row,i)=Va;
          Va=mpc;
          else
          Va=mpc.bus(row,i);
        endif
      endfunction
      function KV=bus_baseKV(mpc,row,KV)
        i=10;
        #set/get pattern.
        if exist('KV','var')
          mpc.bus(row,i)=KV;
          KV=mpc;
          else
          KV=mpc.bus(row,i);
        endif
      endfunction
      function Vmax=bus_Vmax(mpc,row,Vmax)
        i=12;
        #set/get pattern.
        if exist('Vmax','var')
          mpc.bus(row,i)=Vmax;
          Vmax=mpc;
          else
          Vmax=mpc.bus(row,i);
        endif
      endfunction
      function Vmin=bus_Vmin(mpc,row,Vmin)
        i=13;
        #set/get pattern.
        if exist('Vmin','var')
          mpc.bus(row,i)=Vmin;
          Vmin=mpc;
          else
          Vmin=mpc.bus(row,i);
        endif
      endfunction
      %TODO: add function to get generation in case wee need it.
      %then look at specs if we can attach custom  fields. it seems to just be a struct
      %so should be fine.
      #to save to file, docs say se 'add_userfcn' for savecase callback function.
      %question if do we need to save in the case.
      %or, infact, do we even save the case itself. (if time slows it will be needed
      %as a intermediate for continue, but we can easily save our extra fields separately)
      %so keep in mind as we build out.
  endmethods

endclassdef

