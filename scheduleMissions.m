function solution = scheduleMissions(coord_map, nodes, distance_cache, gcDistance, pendingMissions)
    
    % give the next set of missions to execute
    
    nextSet = max_time_matching(size(pendingMissions, 1), size(nodes,1), 100, pendingMissions, distance_cache, gcDistance);
    
    scheduledMissions = zeros(size(nextSet), 2);
    
    % move selected missions into a new queue
    
    for idx = 1 : size(scheduledMissions, 1)
        scheduledMissions(idx, :) = pendingMissions(idx, :);
        pendingMissions.pop(idx);
    end
    
    solution = {scheduledMissions, pendingMissions};

end