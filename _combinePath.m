    function fullpath = _combinePath(P, F)
      if P(end) == '\' || P(end) == '/'
        fullpath = [P, F];
      else
        fullpath = [P, filesep, F]; % Use platform-specific separator
      end
    end

