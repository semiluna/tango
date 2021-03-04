function route = computeRRTStarRoute(start, goal, useLatLongCoords, useCache)

%default to worldCoords
if ~exist('useLatLongCoords', 'var')
    useLatLongCoords = true;
end

%default to using cached results
if ~exist('useCache', 'var')
    useCache = true;
end

%load occupancy map if not already defined
if ~exist('omap', 'var')
    omap = load("work/omap.mat").omap;
end

%translate input coords to world coords
if useLatLongCoords
    start = LongLatToWorld(start);
    goal = LongLatToWorld(goal);
end

%transform start and goal such that they are on the omap coord frame
start = start + omap.GridSize/2;
goal = goal + omap.GridSize/2;
start(3) = 0;
goal(3)=0;

%ensure both the start and goal are inside the map
if start(1) < 40 || start(1) > 1120 || goal(1) < 40 || goal(1) > 1120 || start(2) < 290 || start(2) > 910 || goal(2) < 290 || goal(2) > 910
    route = -3;
    disp("Start or goal state was outside the map");
    return;
end

%plan route
if useCache
    cachedPlanner = memoize(@planRRTStarPath);
    pthObj = cachedPlanner(start, goal);
else
    pthObj = planRRTStarPath(start, goal);
end

%check for errors from planner
if pthObj == -1 || pthObj == -2
   route = pthObj;
   return;
end

%show route on figure
 omap.show;
 hold on;
 plot(pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2); % draw path

%untransform back to world coords
basicRoute = pthObj.States(:,1:2);
basicRoute = basicRoute - omap.GridSize/2;

%get the takeoff and landing z coords
startHeight = getHeight(basicRoute(1,1), basicRoute(1,2));
endHeight = getHeight(basicRoute(length(basicRoute),1), basicRoute(length(basicRoute),2));

%convert from world coords back to latlong
if useLatLongCoords
    for i=1:length(basicRoute)
        longLat = WorldToLongLat([basicRoute(i,1), basicRoute(i,2)]);
        basicRoute(i,1) = longLat(1);
        basicRoute(i,2) = longLat(2);
    end
end

%add z coords to all points and put into nx3 matrix
route = zeros(length(basicRoute)+2, 3);
route(1, :) = [basicRoute(1,1), basicRoute(1,2), startHeight];
for i =1:length(basicRoute)
   route(i+1, :) = [basicRoute(i,1), basicRoute(i,2), 35];
end
route(length(route), :) = [basicRoute(length(basicRoute),1), basicRoute(length(basicRoute), 2), endHeight];
