function json_str = ToPrettyJson(obj, fname,indent)
  if nargin < 3
    indent = '  ';
  endif
  max_depth = 5;
  serialized = RecurseSerialize(obj, 0, max_depth);
  json_str = jsonencode(serialized, "PrettyPrint", true);
  filewrite(fname, json_str);
endfunction

function data = RecurseSerialize(obj, depth, max_depth)
  if depth > max_depth
    data = '[...]';
    return;
  endif

  if isobject(obj)
    data = struct();
    props = properties(obj);
    for i = 1:numel(props)
      pname = props{i};
      try
        val = obj.(pname);
        data.(pname) = RecurseSerialize(val, depth + 1, max_depth);
      catch
        data.(pname) = '<unreadable>';
      end_try_catch
    endfor

  elseif isstruct(obj)
    data = struct();
    fields = fieldnames(obj);
    for i = 1:numel(fields)
      fname = fields{i};
      try
        val = obj.(fname);
        data.(fname) = RecurseSerialize(val, depth + 1, max_depth);
      catch
        data.(fname) = '<unreadable>';
      end_try_catch
    endfor

  elseif iscell(obj)
    data = cell(size(obj));
    for i = 1:numel(obj)
      try
        data{i} = RecurseSerialize(obj{i}, depth + 1, max_depth);
      catch
        data{i} = '<unreadable>';
      end_try_catch
    endfor

  elseif issparse(obj)
    if ~isreal(obj)
      data = abs(full(obj));  % Convert complex sparse to magnitude
    else
      data = full(obj);       % Convert real sparse to full
    endif

  elseif ~isreal(obj)
    data = abs(obj);  % Magnitude of complex values

  elseif isnumeric(obj) || ischar(obj) || islogical(obj)
    data = obj;

  else
    data = sprintf('<unsupported type: %s>', class(obj));
  endif
endfunction





  function filewrite(filename, content)
    fid = fopen(filename, 'w');
    if fid == -1
      error('Unable to open file.');
    endif
    fprintf(fid, '%s', content);
    fclose(fid);
  endfunction

