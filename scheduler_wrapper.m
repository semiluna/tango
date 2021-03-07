% add missions from user interface 

function scheduler_wrapper()
    cachedDistance = memoize(@compute_eucldian_distance);
    
    if ~isempty(hApp.newMission)

        newMission = hApp.newMission;

        start = newMission(1);
        goal = newMission(2);
        
        hApp.newMission = [];
        
        % start and goal are longitude and latitude, groundControl is the
        % middle of the map
    
        route = computeRRTStarRoute(start, goal);
        
        groundControl = [0 0];
        
        gcDistancePickup = computeRRTStarRoute(groundControl, start);
        gcDistanceDelivery = computeRRTStartRoute(goal, groundControl);
        
        nodes = coord_map.size();
        
        % now indexStart is the index of point start and indexGoal is the index of point goal
        
        if coord_map.isKey(start)
            indexStart = coord_map.values(start);
        else
            indexStart = nodes + l;
            nodes = nodes + 1;
            coord_map(start) = indexStart;
        end
        
        if coord_map.isKey(goal)
            indexStart = coord_map.values(goal);
        else
            indexGoal = nodes + 2;
            nodes = nodes + 1;
            coord_map(goal) = indexGoal;
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
       
        mission_queue(right) = [indexStart indexGoal];
        right = right + 1;
        
        solution = max_time_matching(right - left, nodes, 100, mission_queue, distance_cache, gcDistance);
        
        % what do to with the solution?
        
        disp(solution);
        
        hApp.newMission = [];
    end
    
    
end