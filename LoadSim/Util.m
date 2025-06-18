classdef Util

   methods(Static)
    %methods purely for generating multiple CSV files from a 'proto' csv file
    %just :Filename to define the file name of csv
    %then N lines for csv (with comments enabled by ignoring anything after '#')
    %TIP: Must CD into the directory containing the proto file (this is simple helper)


    function new_str = convert_time_to_decimal(input_str)
      % Define regular expression for hh:mm format
      pattern = '(\d{1,2}):(\d{2})';
       FN=@(x)(Util.convert_match(x));
      % Find all matches
      matches = regexp(input_str, pattern, 'match');

      % Convert matches to decimal hours
      if ~isempty(matches)
        converted = cellfun(FN, matches, 'UniformOutput', false);
        % Replace occurrences manually
        for i = 1:length(matches)
          input_str = strrep(input_str, matches{i}, converted{i});
        end
      end

      new_str = input_str;
    end
    function dec_hours = convert_match(match)
      % Extract hours and minutes
      parts = regexp(match, '(\d+):(\d+)', 'tokens'){1};
      hours = str2double(parts{1});
      minutes = str2double(parts{2});

      % Convert to decimal hours
      decimal = hours + (minutes / 60);

      % Format as string
      dec_hours = sprintf('%.2f', decimal);
    endfunction
    function trimmed_str = trim_after_hash(input_str)
      idx = strfind(input_str, "#"); % Find the position of '#'
      if isempty(idx)
        trimmed_str = input_str; % No '#' found, return the original string
      else
        trimmed_str = input_str(1:idx(1)-1); % Extract portion before '#'
      endif
    endfunction
    function lines = parse_text_file(filename)
      fid = fopen(filename, 'r'); % Open the file for reading
      if fid == -1
        error("Could not open file: %s", filename);
      endif
      lines = {};
      idx = 1;

      while ~feof(fid) % Read until end of file
        line = fgetl(fid); % Read a single line
        if ischar(line) % Ensure it's valid text
          lines{idx} = line;
          idx = idx + 1;
        endif
      endwhile

      fclose(fid); % Close the file
    endfunction
    function write_text_file(filename, cellArray)
      fid = fopen(filename, 'w');
      if fid == -1
        error('Could not open file: %s', filename);
      endif

      for i = 1:length(cellArray)
        fprintf(fid, '%s\n', cellArray{i});
      endfor

      fclose(fid);
    endfunction
    %splits file into multiple (just so we can edit faster)
    function ParseProto(filename)
      Lines=Util.parse_text_file(filename);
      ol={};
      FN="";
      for i=1:length(Lines)
        LN=Util.trim_after_hash(Lines{i});
        disp(LN)
        if length(LN)==0
          continue;
        endif
        if(LN(1)==":")
          LN=LN(2:end);
          printf("FN=%s\n",LN);
          if length(ol)>0
            Util.write_text_file(FN,ol);
            ol={};
          endif
          FN=strtrim(LN);
          continue;
        endif
        if length(FN)==0
          continue; #ignore everything until output name defined
        endif
        %not a comment or file definition
        ol{end+1}=Util.convert_time_to_decimal(LN);
        disp(ol{end})
      endfor
      if length(ol)>0
        Util.write_text_file(FN,ol);
        ol={};
      endif
    endfunction
  endmethods
  endclassdef

