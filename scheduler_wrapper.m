% add missions from user interface 

function schedule = scheduler_wrapper(newMission, coord_map, distance_cache, gcDistance, mission_queue, left, right)
    cachedDistance = memoize(@compute_euclidian_distance);
    
    start = newMission(1,:);
    goal = newMission(2,:);
    
    start_key = num2str(start);
    goal_key = num2str(goal);

    % start and goal are longitude and latitude, groundControl is not the
    % middle of the map, its a place easy to navigate to, and where the
    % shed is

    route = computeRRTStarRoute(start, goal);

    groundControl = [52.20954726481548, 0.09000709627050027];

    gcDistancePickup = computeRRTStarRoute(groundControl, start);
    gcDistanceDelivery = computeRRTStarRoute(goal, groundControl);

    nodes = coord_map.size(1);
    % now indexStart is the index of point start and indexGoal is the index of point goal

    if isKey(coord_map, start_key)
        indexStart = coord_map(start_key);
    else
        indexStart = nodes;
        nodes = nodes + 1;
        coord_map(start_key) = indexStart;
    end
    
    if isKey(coord_map, goal_key)
        indexGoal = coord_map(goal_key);
    else
        indexGoal = nodes;
        nodes = nodes + 1;
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
    for index = left : (right - 1)
        mission = mission_queue(index); % pair of indices (indexStart, indexGoal)
        indexNextStart = mission(2); % next pickup point

        nextRoute = computeRRTStarRoute(indexGoal, indexNextStart);
        distance_cache(indexGoal, indexNextStart) = cachedDistance(nextRoute);
        distance_cache(indexNextStart, indexGoal) = cachedDistance(nextRoute);
    end


   % add read mission to the mission queue

%     mission_queue(right) = [indexStart indexGoal];
    
    mission_queue = cat(1, mission_queue, [indexStart indexGoal]);

    right = right + 1;
    solution = max_time_matching(right - left, nodes, 100, mission_queue, distance_cache, gcDistance);
    
    % what do to with the solution?
    
    schedule = solution;
    
end