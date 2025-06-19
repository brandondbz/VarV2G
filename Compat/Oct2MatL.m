%untested.
function Oct2Mat(SrcDir, DstDir)
  if ~exist(SrcDir, 'dir')
    error('Source directory does not exist: %s', SrcDir);
  end

  if ~exist(DstDir, 'dir')
    mkdir(DstDir);
  end

  % Copy all files from SrcDir to DstDir
  files = dir(fullfile(SrcDir, '*'));
  for i = 1:length(files)
    if ~files(i).isdir
      copyfile(fullfile(SrcDir, files(i).name), fullfile(DstDir, files(i).name));
    end
  end

  % Find all .m files in DstDir
  mFiles = dir(fullfile(DstDir, '*.m'));
  for i = 1:length(mFiles)
    filePath = fullfile(DstDir, mFiles(i).name);
    modifyEndStatements(filePath);
  end
end

function modifyEndStatements(filePath)
  fid = fopen(filePath, 'r');
  if fid == -1
    error('Could not open file: %s', filePath);
  end

  lines = {};
  while ~feof(fid)
    line = fgetl(fid);
    % Replace specific keywords with formatted "end%" comments
    line = regexprep(line, 'endfunction', 'end%function');
    line = regexprep(line, 'endfor', 'end%for');
    line = regexprep(line, 'endmethods', 'end%methods');
    line = regexprep(line, 'endproperties', 'end%properties');
    line = regexprep(line, 'endwhile', 'end%while');
    line = regexprep(line, 'endif', 'end%if');
    line = regexprep(line, '^\s*#', '%'); % Replace leading # with %

    lines{end+1} = line;
  end
  fclose(fid);

  % Write modified content back to the file
  fid = fopen(filePath, 'w');
  for i = 1:length(lines)
    fprintf(fid, '%s\n', lines{i});
  end
  fclose(fid);
end

