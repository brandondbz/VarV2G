classdef QLearning
    properties
        QTable  % State-action value table
        alpha   % Learning rate
        gamma   % Discount factor
        epsilon % Exploration rate
        actions % List of possible actions
        stateMap % SOM for the state
        actionTable
    end

    methods
        function Q=Act(obj, V, SI, QLim) % rename as needed, but have the inputs come in here.

        endfunction

        function obj = QLearning(numStates, minState, maxState, numActions,minAction,maxAction, alpha, gamma, epsilon)
            obj.QTable = zeros(numStates, numActions);
            obj.alpha = alpha;
            obj.gamma = gamma;
            obj.epsilon = epsilon;
            obj.actions = 1:numActions;
            obj.actionTable=ActionTable(numActions, minAction, maxAction);
            obj.stateMap=OnlineSom(numStates, learningRate, threshold,minState, maxState);
        end

        function action = selectAction(obj, state)
            if rand < obj.epsilon
                %for exploration, we will apply our filter next.
                action = randi(length(obj.actions)); % Explore
            else
                [~, action] = max(obj.QTable(state, :)); % Exploit
            end
        end

        function obj = updateQTable(obj, state, action, reward, nextState)
            maxNextQ = max(obj.QTable(nextState, :));
            obj.QTable(state, action) = obj.QTable(state, action) + obj.alpha * (reward + obj.gamma * maxNextQ - obj.QTable(state, action));
        end
    end
end

