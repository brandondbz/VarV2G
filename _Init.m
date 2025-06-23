
if ~exist('VAR_VTG_INIT','var')
  % Define the directory to add
  % we will have at least three basic branches
  % the 'base sim' to let us run psim transparently
  % and 'monte carlo' to let us adjust our loads/availability according to random funcs
  % and 'system' to contain our actual system
  if exist('contains')==0
    contains=@(a,b)__contains(a,b);
  endif


  LogPath= _combinePath(cd, "\\Log\\")
  logi = dlmread(_combinePath(LogPath, "CT.txt"))(1);
  logi+=1;
  LOUT= _combinePath(LogPath, strcat("Log_", num2str(logi), ".txt"));
  dlmwrite(_combinePath(LogPath, "CT.txt"),logi)
  directorysToAdd = {_combinePath( cd, '\BaseSim'),  _combinePath( cd,'\SysUnderTest'), ...
  _combinePath( cd,'\LoadSim'),_combinePath( cd,'\Compat')};
  diary(LOUT);
  diary on;
  printf("Log initialized: %s\r\n", LOUT);

  for directoryToAdd = directorysToAdd
    % Check if the directory is already in the path
    directoryToAdd=directoryToAdd{1};
    directoryToAdd=strrep(directoryToAdd,"\\\\","\\");
    if ~contains(path, directoryToAdd)
        addpath(directoryToAdd);
        disp(['Directory added to path: ', directoryToAdd]);
    else
        disp(['Directory already in path: ', directoryToAdd]);
    end
  end
  clear("directoryToAdd","directorysToAdd")
  %initialize the vars/dirs/etc.
  %this is for the one-time (environment) inits/anything to initialize after
  %'clear all'
  disp("Initilized");
  VAR_VTG_INIT=1;

  %Global parameters
  %deltaT, the time unit (in hours).
  Config.Inst().pset("deltaT",1);
  %set default the distribution version.
  Config.Inst().pset('PowSrc', _combinePath(cd, "BaseSim\\V2G_AI_Radial.m"));
else
  diary on;
endif

