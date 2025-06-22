%using a LUT for the actions (with the actions choosen linearly spaced, similar to a histogram
classdef ActionTable < handle
    properties
        actionPrototypes  % Stores action vectors
        MIN
        MAX
    endproperties

    methods
        function obj = ActionTable(K, minVector, maxVector)
          if length(minVector)~=length(maxVector)
            error("min and max vectors must be same size!");
          endif
            % Generate K equally spaced initial action vectors
            obj.actionPrototypes = obj.initializeActionVectors(K, minVector, maxVector);
            obj.MIN=minVector;
            obj.MAX=maxVector;
        endfunction

        function actionVectors = initializeActionVectors(obj, K, minVector, maxVector)
            % Compute equally spaced points along each dimension
            numDims = length(minVector);
            actionVectors = zeros(K, numDims);
            for d = 1:numDims
                actionVectors(:, d) = linspace(minVector(d), maxVector(d), K)';
            endfor
            actionVectors(K+1,:)=zeros(1, numDims);
        endfunction
       function A=ValidActions(minQ,maxQ)
         A=zeros(1,size(obj.actionPrototypes,1));
         for i=1:length(A)
           if sum(minQ>obj.actionPrototypes(i))>0 || sum(maxQ<obj.actionPrototypes)>0
             A(i)=0; %if any outside of range then don't pick it.
           else
             A(i)=1; %otherwise ok
           endif
         endfor
       endfunction
       function expandActionSpace(obj,  minVector_new, maxVector_new)
            minVector_new=min(minVector_new, obj.MIN);
            maxVector_new=max(maxVector_new, obj.MAX);
            if isequal(minVector_new, obj.MIN) && isequal(maxVector_new,obj.MAX)
              return;
            endif
            S_new=(obj.MIN-minVector_new)^2
            K_new;
            %two steps. one, subtract the old min/max reletive (so NewMax-Max and NewMin-Min)
            %then linspace in that space only
            %finally Re-append (+ve to be max+rel) and (-ve to be Min-rel)
            %the order is the same since new min is always <= old, and new max >= max
            %so new min-old min is <=0 and new max-old max >=0
            minVector_rel=minVector_new-obj.MIN;
            maxVector_rel=obj.maxVector_new-obj.MAX;

            % Generate additional equally spaced action vectors
            newActions = obj.initializeActionVectors(K_new, minVector_rel, maxVector_rel);

            %now shift back to true
            for i=1:size(newActions,1)
              %can likely optimize to vector operations
              for j=1:size(newActions,2)
                if newActions(i,j)>0
                  newActions(i,j)+=obj.MAX(j);
                elseif newActions(i,j)<0
                  newActions(i,j)+=obj.Min(j);
                endif
              endfor
            endfor

            % Append new actions to existing prototypes
            obj.actionPrototypes = [obj.actionPrototypes; newActions];
        endfunction

        function actionVector = getAction(obj, actionIndex)
          actionVector=obj.actionPrototypes(actionIndex,:);
        endfunction

    endmethods
endclassdef

