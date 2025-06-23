function mpc = V2G_AI_Radial()
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 1;

%% bus data
% bus_i type Pd Qd  Gs Bs area Vm Va baseKV zone Vmax Vmin
%{
mpc.bus = [
    1   3   0.0   0.0   0   0   1   1.00   0   12.47 1   1.05 0.95;
    2   1   0.1   0.06  0   0   1   1.00   0   12.47 1   1.05 0.95;
    3   1   0.09  0.04  0   0   1   1.00   0   12.47 1   1.05 0.95;
    4   1   0.12  0.08  0   0   1   1.00   0   12.47 1   1.05 0.95;
    5   1   0.06  0.03  0   0   1   1.00   0   12.47 1   1.05 0.95;
];
%}
mpc.bus = [
    1   3   0.0   0.0   0   0   1   1.00   0   12.47 1   1.05 0.95;
    2   1   0.2   0.06  0   0   1   1.00   0   12.47 1   1.05 0.95;
    3   1   0.2  0.04  0   0   1   1.00   0   12.47 1   1.05 0.95;
    4   1   0.2  0.08  0   0   1   1.00   0   12.47 1   1.05 0.95;
    5   1   0.1  0.2  0   0   1   1.00   0   12.47 1   1.05 0.95;
];

%% generator data
% bus Pg Qg Qmax Qmin Vg mBase status Pmax Pmin
mpc.gen = [
    1  0.6  0.3  1  -1  1.00  1  1  1  0;
];

%% branch data
% fbus tbus r     x       b   rateA rateB rateC ratio angle status angmin angmax
%{
mpc.branch = [
    1  2  0.010  0.085  0   100 100 100  0  0  1  -360  360;
    2  3  0.012  0.10   0   100 100 100  0  0  1  -360  360;
    3  4  0.015  0.12   0   100 100 100  0  0  1  -360  360;
    4  5  0.017  0.14   0   100 100 100  0  0  1  -360  360;
];
%}
mpc.branch = [
    1  2  0.050  0.085  0   100 100 100  0  0  1  -360  360;
    2  3  0.052  0.10   0   100 100 100  0  0  1  -360  360;
    3  4  0.055  0.12   0   100 100 100  0  0  1  -360  360;
    4  5  0.057  0.14   0   100 100 100  0  0  1  -360  360;
];

%% generator cost data
% 1 startup shutdown n c(n-1) ... c0
mpc.gencost = [
    2 0 0 2 30 0;
];

