classdef QLearning
    properties
        QTable  % State-action value table
        alpha   % Learning rate
        gamma   % Discount factor
        epsilon % Exploration rate
        actions % List of possible actions
        stateMap % SOM for the state
        actionTable
        maxQ
        minQ
    end

    methods

        function obj = QLearning( minV, minSI, maxV, maxSI, minQ,  maxQ)
            dcfg=struct('alpha', 0.1, 'gamma',0.1,'epsilon',0.01,'som_learningRate',0.1,'som_threshold',0.1,'numStates',100,'numActions',100);

            cfg=Config.Inst();
            dcfg=cfg.pget("QSettings",dcfg);
            obj.alpha=dcfg.alpha;
            obj.gamma=dcfg.gamma;
            obj.epsilon=dcfg.epsilon;
            learningRate=dcfg.som_learningRate;
            threshold=dcfg.som_threshold;
            numStates=dcfg.numStates;
            numActions=dcfg.numActions;
            %pack state
            minState=[minV, minSI];
            maxState=[maxV, maxSI];

            obj.minQ=minQ;
            obj.maxQ=maxQ;

            obj.QTable = zeros(numStates, numActions);
            obj.actions = 1:numActions;
            obj.actionTable=ActionTable(numActions, minQ, maxQ);
            obj.stateMap=OnlineSom(numStates, learningRate, threshold, minState, maxState);
        end

        function Q=Act(obj, V, SI,  minQ, maxQ) % rename as needed, but have the inputs come in here.
          obj.minQ=minQ;
          obj.maxQ=maxQ;
          %require row vectors
          if size(V,1)>size(V,2)
            V=V';
          endif
          if size(SI,1)>size(SI,2)
            V=V';
          endif
          %pack state
          state=[V, SI];
          st=obj.stateMap.classify(state)
          ac=obj.selectAction(st);

        endfunction
        function a=lrandi(obj)
          VS=obj.actionTable.ValidActions(obj.minQ,obj.maxQ);
          QTemp=obj.QTable(ac,:); %pick row based on current state
          QTemp(~VS)=-inf; %set all invalid actions
          a=randi(length(QTemp));
          while VS(a)==0
            a=randi(length(QTemp));
          endwhile
        endfunction
        function a=lmax(obj,ac)
          VS=obj.actionTable.ValidActions(obj.minQ,obj.maxQ);
          QTemp=obj.QTable(ac,:); %pick row based on current state
          QTemp(~VS)=-inf; %set all invalid actions
          [~,a]=max(QTemp);
        endfunction
        function action = selectAction(obj, state)
            if rand < obj.epsilon
                %for exploration, we will apply our filter next.
                action = obj.lrandi(length(obj.actions)); % Explore
            else

                action=obj.lmax(state) % Exploit
            end
        end

        function obj = updateQTable(obj, state, action, reward, nextState)
            maxNextQ = max(obj.QTable(nextState, :));
            obj.QTable(state, action) = obj.QTable(state, action) + obj.alpha * (reward + obj.gamma * maxNextQ - obj.QTable(state, action));
        end
    end
end

