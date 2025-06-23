classdef ActionTable
  properties
    actions     % Matrix: each row is an N-d action
    k           % Actual number of actions (≥ requested)
    nDims       % Number of dimensions
  endproperties

  methods
    function obj = ActionTable(k_requested, MIN, MAX)
      MIN = MIN(:)'; MAX = MAX(:)';
      obj.nDims = length(MIN);
      if any(MIN == MAX)
      printf('Notice: Invalid input range in one or more dimensions: MIN = [%s], MAX = [%s]', num2str(MIN), num2str(MAX));
      endif
      divisions = ceil(k_requested ^ (1 / obj.nDims));
      obj.k = divisions ^ obj.nDims;
      printf("ActionTable Division: %d, k: %d\n", divisions, obj.k);

      F=0;

      grid = cell(1, obj.nDims);
      for d = 1:obj.nDims
        if MIN(d)~=MAX(d)
          grid{d} = linspace(MIN(d), MAX(d), divisions);
        else%default to zeros (since min(d)==max(d) when the local Q is 0 (e.g. no EV at bus).
        grid{d}=zeros(1,divisions);
        endif

        if any(isinf(grid{d}))
          F=1;
          MIN
          MAX
          grid
          error("Bad Grid");
        endif
      endfor

      [meshgrid_out{1:obj.nDims}] = ndgrid(grid{:});
      obj.actions = zeros(obj.k, obj.nDims);
      for d = 1:obj.nDims
        obj.actions(:, d) = meshgrid_out{d}(:);
      endfor
      if any(isinf(obj.actions) || F)
        s="";
        grid
        meshgrid_out
        error("Problem in constructor %s",s);
      endif
      printf("Object Actions\n");
      Record.Inst().pset("actionTable",obj.actions);
    endfunction

    function flags = ValidActions(obj, MIN, MAX)
      MIN = MIN(:)'; MAX = MAX(:)';
      within_min = bsxfun(@ge, obj.actions, MIN);
      within_max = bsxfun(@le, obj.actions, MAX);
      flags = all(within_min & within_max, 2);
    endfunction

    function a = GetElement(obj, idx)
      a = obj.actions(idx, :);
    endfunction

    function idx = FindClosest(obj, vec)
      diffs = obj.actions - vec(:)';
      dists = sum(diffs .^ 2, 2);
      [~, idx] = min(dists);
    endfunction
  endmethods
endclassdef

