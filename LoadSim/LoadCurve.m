classdef LoadCurve < handle
  properties
    X;
    Y;
  endproperties
  methods
    %normalize to a value.
    function NormalizeYTo(obj,V100)
      nF=V100/max(obj.Y)
      obj.Y=obj.Y.*nF;
    endfunction
    function ysc=Interpolate(obj,X)
      k=find(obj.X>X);
      if length(k)==0
        ysc=obj.Y(end);%apply window by assuming consted before X{0) and after(X(end))
        return;
      endif
      k=k(1);
      if k==1
        ysc=obj.Y(1);
        return;
      endif
      y=obj.Y(k);
      yy=obj.Y(k-1);
      x=obj.X(k);
      xx=obj.X(k-1);
      xsc=(X-xx)/(x-xx);
      ysc=(y-yy)*xsc+yy; %interpolate
    endfunction
    function obj=LoadCurve(X,Y)
        obj.Y=Y;
        obj.X=X;
        obj.NormalizeYTo(1);%we multiply by Q,P
    endfunction
  endmethods
  methods(Static)
    function LC=Load(fn)
      M=dlmread(fn);
      LC=LoadCurve(M(:,1),M(:,2));
    endfunction
    function LC=Create(X,Y)
      LC=LoadCurve(X,Y);
    endfunction
    function LC=LoadWebPlotDigitizerProject(fn)
      LC={};
      p=1;
      JS=jsondecode(fileread(fn));
      JD=JS.datasetColl;
      for ii=1:length(JD)
        DS=[JD(ii).data.value]';
        %can be out of order, so sort by x first
        [DS(:,1), i]=sort(DS(:,1));
        DS(:,2)=DS(:,2)(i);
        LS=LoadCurve.Create(DS(:,1),DS(:,2));
        D=struct();
        D.name=JD(ii).name;
        D.data=LS;
        LC{p}=D;
        p+=1;
      endfor
    endfunction

    function LS=LoadSet(Dir,Pat)
      LS={};
      BaseFile=@(f)f(1:([find(f=='.')-1 length(f)](1)))
      p=1;
      if exist("contains")==0
        contains=@(a,b)__contains(a,b);
      endif
      x=dir(Dir);
      for i=1:length(x)
        name=_combinePath(x(i).folder, x(i).name)
        Pat
        if contains(name,Pat)
          LS=[LS LoadCurve.LoadWebPlotDigitizerProject(name)];
        endif
      endfor
    endfunction
  endmethods

endclassdef

