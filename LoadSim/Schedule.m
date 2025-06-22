classdef Schedule
  properties
    name
    AEV
  endproperties
  methods
  function obj=Schedule(fname,name)
    M=dlmread(fname);
    for l=1:size(M,1)
      if M(l,2)<M(l,1)
        NM=[0,M(l,2)];
        M(l,2)=24;
        M(end+1,:)=NM;
      endif
    endfor
    obj.name=name;
     deltaT=Config.Inst().pget("deltaT");
    i=(1:ceil(24/deltaT))';
    t=(i*deltaT)';
    obj.AEV=ones(size(i));
    for k = 1:length(i)

      v=1; %assume at home
      for l=1:size(M,1)
        if t(k)>M(l,1) && t(k)<M(l,2)
          v=0; %unless inside of an 'out of home' window
        endif
      endfor
      obj.AEV(k)=v;
    endfor
  endfunction
  endmethods
  methods(Static)
   function LS=LoadSet(Dir,Pat)
      LS={};
      BaseFile=@(f)f(1:([find(f=='.')-1 length(f)](1)));
      p=1;
      if exist("contains")==0
        contains=@(a,b)__contains(a,b);
      endif
      x=dir(Dir);
      for i=1:length(x)
        name=_combinePath(x(i).folder, x(i).name);
        Pat;
        if contains(name,Pat)
          LS{end+1}=Schedule(name,x(i).name);
        endif
      endfor
    endfunction
  endmethods
endclassdef


