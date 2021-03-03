% add missions from user interface 

function scheduler_wrapper() 
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
            coord_map(start) = indexStart;
        end
        
        if coord_map.isKey(goal)
            indexStart = coord_map.values(goal);
        else
            indexGoal = nodes + 2;
            coord_map(goal) = indexGoal;
        end
        
        nodes = nodes + 2;
        
        % add distances to the adjacency matrix
        
        % route_cache([indexStart indexGoal]) = route; %list of intermediate points
        % route_cache([indexGoal indexStart]) = route; 
        % distance_cache(indexStart, indexGoal) = compute_euclidian_distance(route); %total distance of route
        % distance_cache(indexGoal, indexStart)  = distance_cache(indexStart, indexGoal);
        
        % remember GroundControl routes
        
        % groundControl_cache(indexStart) = gcDistancePickup;
        % groundControl_cache(indexGoal) = gcDistanceDelivery;
        
        % if gcDistance(indexStart) == 0
        %    gcDistance(indexStart) = compute_euclidian_distance(gcDistancePickup);
        % end
        
        % if gcDistance(indexGoal) == 0
        %    gcDistance(indexGoal) = compute_euclidian_distance(gcDistanceDelivery);
        % end
        
        % compute distances from point "goal" to every other possible
        % "pickup" point
        for index = left : (right - 1)
            mission = mission_queue(index); % pair of indices (indexStart, indexGoal)
            indexNextStart = mission(2);
            
            if ~route_cache.isKey([indexGoal indexNextStart])
                nextRoute = computeRRTStarRoute(indexGoal, indexNextStart);
                % route_cache([indexGoal indexNextStart]) = nextRoute;
                % route_cache([indexNextStart indexGoal]) = nextRoute;
                % distance_cache(indexGoal, indexNextStart) = compute_euclidian_distance(route);
                % distance_cache(indexNextStart, indexGoal) = distance_cache(indexGoal, indexNextStart);
            end       
        end
        
        
       % add read mission to the mission queue
       
        mission_queue(right) = [indexStart indexGoal];
        right = right + 1;
        
        % compute a new set of missions
        mission_list = mission_queue(left:(right-1));
        
        solution = max_time_matching(right - left, nodes, 100, mission_list, distance_cache, gcDistance);
        
        % what do to with the solution?
        
        disp(solution);
    
    end
    
    
end