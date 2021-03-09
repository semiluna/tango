function solution = updateState(newMission, groundControl, coord_map, nodes, distance_cache, gcDistance, pendingMissions)
    
    cachedDistance = memoize(@compute_euclidian_distance);

    start = newMission(1,:);
    goal = newMission(2,:);
    
    start_key = num2str(start);
    goal_key = num2str(goal);

    % start and goal are longitude and latitude, groundControl is not the
    % middle of the map, its a place easy to navigate to, and where the
    % shed is

    route = computeRRTStarRoute(start, goal);

    % groundControl = [52.20954726481548, 0.09000709627050027];

    gcDistancePickup = computeRRTStarRoute(groundControl, start);
    gcDistanceDelivery = computeRRTStarRoute(goal, groundControl);

    % now indexStart is the index of point start and indexGoal is the index of point goal
    
    if isKey(coord_map, start_key)
        indexStart = coord_map(start_key);
    else
        indexStart = size(nodes,1) + 1;
        nodes(indexStart,:) = start;
        coord_map(start_key) = indexStart;
    end
    
    if isKey(coord_map, goal_key)
        indexGoal = coord_map(goal_key);
    else
        indexGoal = size(nodes,1) + 1;
        nodes(indexGoal,:) = goal;
        coord_map(goal_key) = indexGoal;
    end


    % add distances to the adjacency matrix

    distance_cache(indexStart, indexGoal) = cachedDistance(route);
    distance_cache(indexGoal, indexStart) = cachedDistance(route);

    % remember GroundControl routes

    gcDistance(indexStart) = cachedDistance(gcDistancePickup);
    gcDistance(indexGoal) = cachedDistance(gcDistanceDelivery);

    % compute distances from point "goal" to every other possible
    % "pickup" point
    
    queue_size = size(pendingMissions, 1);
    for index = 1 : queue_size
        mission = pendingMissions(index, :); % pair of indices (indexStart, indexGoal)
        disp(mission);
        indexNextStart = mission(2); % next pickup point

        nextRoute = computeRRTStarRoute(nodes(indexGoal, :), nodes(indexNextStart, :));
        distance_cache(indexGoal, indexNextStart) = cachedDistance(nextRoute);
        distance_cache(indexNextStart, indexGoal) = cachedDistance(nextRoute);
    end
    
    pendingMissions = cat(1, pendingMissions, [indexStart indexGoal]);
    
    solution = {coord_map, nodes, distance_cache, gcDistance, pendingMissions};
end
