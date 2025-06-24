classdef QLearning<handle
    properties
        QTable  % State-action value table
        alpha   % Learning rate
        gamma   % Discount factor
        epsilon % Exploration rate
        actions % List of possible actions
        stateMap % SOM for the state
    end

    methods

        function obj = QLearning( minV,maxV, dQ)
            dcfg=struct('alpha', 0.1, 'gamma',0.1,'epsilon',0.01,'som_learningRate',0.1,'som_threshold',0.1,'numStates',100,'numActions',100);

            cfg=Config.Inst();
            dcfg=cfg.pget("QSettings",dcfg);
            obj.alpha=dcfg.alpha;
            obj.gamma=dcfg.gamma;
            obj.epsilon=dcfg.epsilon;
            learningRate=dcfg.som_learningRate;
            threshold=dcfg.som_threshold;
            numStates=dcfg.numStates;
            numActions=length(minV)*2-1;

            %pack state
            minState=[minV];
            maxState=[maxV];

            obj.stateMap=OnlineSom(numStates, learningRate,  minState, maxState);
            printf("Num States=%d,Acts=%d\n",numStates, numActions);
            obj.QTable = zeros(numStates, numActions);
            obj.actions = [2:length(minV) 2:length(minV) 0;-dQ*ones(1,(length(minV)-1)) dQ*ones(1,length(minV)-1) 0];

        end

        function [st,ac]=Act(obj, V) % rename as needed, but have the inputs come in here.

          %require row vectors
          if size(V,1)>size(V,2)
            V=V';
          endif

          %pack state
          state=[V];
          st=obj.stateMap.classify(state)
          ac=obj.selectAction(st);
        endfunction

        function action = selectAction(obj, state)
            if rand < obj.epsilon
                %for exploration, we will apply our filter next.
                action = randi(size(obj.actions,2)); % Explore
            else
                [~,action]=max(obj.QTable(state,:)); % Exploit
            end
        end

        function obj = updateQTable(obj, state, action, reward)

          sa=[state,action]
            Reward= obj.QTable(state, action) + obj.alpha * (reward + - obj.QTable(state, action))
            obj.QTable(state, action) =Reward
            Record.Inst().pset("QTable",obj.QTable);
        end
    end
end

