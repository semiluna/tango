function solution = scheduleMissions(coord_map, nodes, distance_cache, gcDistance, pendingMissions)
    
    % give the next set of missions to execute
    
    nextSet = max_time_matching(size(pendingMissions, 1), size(nodes,1), 10000, pendingMissions, distance_cache, gcDistance);
    
    scheduledMissions = zeros(size(nextSet, 1), 2);
    
    % move selected missions into a new queue
    
    for idx = 1 : size(scheduledMissions, 1)
        scheduledMissions(idx, :) = pendingMissions(nextSet(idx), :);
        pendingMissions(nextSet(idx), :) = [-1 -1];
    end
    
    temp = [];
    
    for idx = 1:size(pendingMissions,1)
        if pendingMissions(idx,:) ~= [-1 -1]
            temp(size(temp,1)+1,:) = pendingMissions(idx,:);
        end
    end
    
    solution = {scheduledMissions, temp};

end