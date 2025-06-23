classdef OnlineSom<handle
    properties
        prototypes  % Cluster prototypes (each row is a class center)
        learningRate % Adaptive learning rate
    end

    methods
        function obj = OnlineSom(k, learningRate, minVector, maxVector)
          if length(minVector)~=length(maxVector)
            error("min and max vectors must be same size!");
          endif
          inputDim=length(minVector);
          obj.prototypes=obj.initializeClusters(k, minVector,maxVector);
            %obj.prototypes = []; %rand(1, inputDim); % Initialize with one random class (0 may be better)
            obj.learningRate = learningRate;
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

                % Update existing prototype using online learning
                obj.prototypes(classID, :) = obj.prototypes(classID, :) + obj.learningRate * (stateVector - obj.prototypes(classID, :));



        endfunction


    endmethods
endclassdef

