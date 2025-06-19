classdef OnlineSOM<handle
    properties
        prototypes  % Cluster prototypes (each row is a class center)
        learningRate % Adaptive learning rate
        threshold    % Threshold for creating new clusters
    end

    methods
        function obj = OnlineSOM(k, learningRate, threshold,minVector, maxVector, mergeThreshold, callbackFunc)
          if length(minVector)~=length(maxVector)
            error("min and max vectors must be same size!");
          endif
          inputDim=length(minVector);
          obj.prototypes=initializeClusters(k, minVector,maxVector);
            %obj.prototypes = []; %rand(1, inputDim); % Initialize with one random class (0 may be better)
            obj.learningRate = learningRate;
            obj.threshold = threshold;
            if exist('mergeThreshold','var') && exist('callbackFunc','var')
              obj.mergeThreshold = mergeThreshold;
              obj.callbackFunc = callbackFunc;
            else
              obj.mergeThreshold=0;
            endif
        end
        function clusters = initializeClusters(obj, K, minVector, maxVector)
            numDims = length(minVector);
            clusters = zeros(K, numDims);
            for d = 1:numDims
                clusters(:, d) = linspace(minVector(d), maxVector(d), K)';
            end
        end
        function classID = classify(obj, stateVector)
            % Compute distances to all existing prototypes
            distances = sqrt(sum((obj.prototypes - stateVector).^2, 2));
            [minDist, classID] = min(distances);

            % If stateVector is too different, create a new class
            if minDist > obj.threshold
                obj.prototypes = [obj.prototypes; stateVector]; % Add new class
                classID = size(obj.prototypes, 1);
            else
                % Update existing prototype using online learning
                obj.prototypes(classID, :) = obj.prototypes(classID, :) + obj.learningRate * (stateVector - obj.prototypes(classID, :));
                %simple to handle here, but managing the Q-Matrix in the next step
                %could get complicated. So we will start disabled.
                if obj.mergeThreshold~=0
                  % Check for probabilistic merging
                   obj.probabilisticMerge();
                endif
            end
        end

        function  probabilisticMerge(obj)
            numClasses = size(obj.prototypes, 1);
            mergeCandidates = [];

            % Compute pairwise distances between prototypes
            for i = 1:numClasses
                for j = i+1:numClasses
                    distance = sqrt(sum((obj.prototypes(i, :) - obj.prototypes(j, :)).^2));
                    if distance < obj.mergeThreshold
                        mergeCandidates = [mergeCandidates; i, j, distance];
                    end
                end
            end

            % Execute callback to determine which merges should occur
            if ~isempty(mergeCandidates)
                mergeDecisions = obj.callbackFunc(mergeCandidates);
                obj.performMerges(mergeCandidates, mergeDecisions);
            end
        end

        function  performMerges(obj, mergeCandidates, mergeDecisions)
            for k = 1:size(mergeCandidates, 1)
                if mergeDecisions(k) == 1
                    i = mergeCandidates(k, 1);
                    j = mergeCandidates(k, 2);

                    % Merge classes by averaging their prototypes
                    obj.prototypes(i, :) = (obj.prototypes(i, :) + obj.prototypes(j, :)) / 2;

                    % Remove merged prototype
                    obj.prototypes(j, :) = [];
                end
            end
        end
    end
end

