classdef QLearning<handle
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

        function obj = QLearning( minV, minP, maxV,maxP, minQ,  maxQ)
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
            minState=[minV, minP,minQ];
            maxState=[maxV,maxP, maxQ];

            obj.minQ=minQ;
            obj.maxQ=maxQ;

            if any(isinf(minQ)) || any(isinf(maxQ))
              error("INF in Q");
            endif

            obj.actionTable=ActionTable(numActions, minQ, maxQ);
            printf("QTable Target ActNum: %d, actual: %d\n\n", numActions, obj.actionTable.k);
            numActions=obj.actionTable.k; %action table keeps integer even over all dims, which means there can be some rounding error resulting in k slightly higher.

            obj.stateMap=OnlineSom(numStates, learningRate,  minState, maxState);
            printf("Num States=%d,Acts=%d\n",numStates, numActions);
            obj.QTable = zeros(numStates, numActions);
            obj.actions = 1:numActions;
        end

        function [st,ac, QA]=Act(obj, V, P, Q,  minQ, maxQ) % rename as needed, but have the inputs come in here.
          obj.minQ=minQ;
          obj.maxQ=maxQ;
          %require row vectors
          if size(V,1)>size(V,2)
            V=V';
          endif
          if size(P,1)>size(P,2)
            Q=Q';
          endif
          %pack state
          state=[V, P,Q];
          st=obj.stateMap.classify(state)
          ac=obj.selectAction(st);
          QA=obj.actionTable.GetElement(ac);
          if any(isinf(QA))
            state
            obj.actionTable.actions
            error("Invalid action");
          endif
        endfunction


        function a=lrandi(obj)
          VS=obj.actionTable.ValidActions(obj.minQ,obj.maxQ);
          a=randi(length(VS));
          while VS(a)==0
            a=randi(length(VS));
          endwhile
          %Since random a is preselected above. Also, 'ValidActions' is already in use
          %QTemp=obj.QTable(a,:); %pick row based on current state
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
                action = obj.lrandi(); % Explore
            else
                action=obj.lmax(state) % Exploit
            end
        end

        function obj = updateQTable(obj, state, action, reward, V,P,Q)
          nextStateS=[V, P,Q];
          nextState=obj.stateMap.classify(state);
            maxNextQ = max(obj.QTable(nextState, :));
            sa=[state,action]
            Reward= obj.QTable(state, action) + obj.alpha * (reward + obj.gamma * maxNextQ - obj.QTable(state, action))
            obj.QTable(state, action) =Reward
            Record.Inst().pset("QTable",obj.QTable);
        end
    end
end

