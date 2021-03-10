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
    start = LatLongToWorld(start);
    goal = LatLongToWorld(goal);
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

%make the lower coord first, so the cache works in both directions
if start(1) < goal(1)
    coordsFlipped = false;
elseif start(1) == goal(1)
    coordsFlipped = start(2) > goal(2);
else
    coordsFlipped = true;
end

if coordsFlipped
    [start, goal] = deal(goal, start);
end

%plan route
if useCache
    cachedPlanner = memoize(@planRRTStarPath);
    pthObj = cachedPlanner(start, goal);
    
    %make sure we are not using a cached version of a failed hit
    if pthObj == -2
        pthObj = planRRTStarPath(start, goal);
    end
else
    pthObj = planRRTStarPath(start, goal);
end

%check for errors from planner
if pthObj == -1 || pthObj == -2
   route = pthObj;
   return;
end

%show route on figure
%   omap.show;
%   hold on;
%   plot(pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2); % draw path

%untransform back to world coords
basicRoute = pthObj.States(:,1:2);
basicRoute = basicRoute - omap.GridSize/2;

%flip coords back if needed
if coordsFlipped
   basicRoute = flip(basicRoute);
end

%get the takeoff and landing z coords
landingOffset = 2;
startHeight = getHeight(basicRoute(1,1), basicRoute(1,2)) + landingOffset;
endHeight = getHeight(basicRoute(length(basicRoute),1), basicRoute(length(basicRoute),2)) + landingOffset;

%convert from world coords back to latlong
if useLatLongCoords
    for i=1:length(basicRoute)
        longLat = WorldToLatLong([basicRoute(i,1), basicRoute(i,2)]);
        basicRoute(i,1) = longLat(1);
        basicRoute(i,2) = longLat(2);
    end
end

%add z coords to all points and put into nx3 matrix
route = zeros(length(basicRoute)+2, 3);
route(1, :) = [basicRoute(1,1), basicRoute(1,2), startHeight];

flightHeight = 20;

for i =1:length(basicRoute)
   route(i+1, :) = [basicRoute(i,1), basicRoute(i,2), flightHeight];
end
route(length(route), :) = [basicRoute(length(basicRoute),1), basicRoute(length(basicRoute), 2), endHeight];
