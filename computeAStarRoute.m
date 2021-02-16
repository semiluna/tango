function route = computeAStarRoute(start, goal)

%create occupancy map if not already defined
if ~exist('omap', 'var')
    omap = createOccupancyMap();
end

%transform start and goal such that they are on the omap coord frame
start = start + omap.GridSize/2;
goal = goal + omap.GridSize/2;

start = flip(start);
goal = flip(goal);
start(1) = omap.GridSize(1) - start(1);
goal(1) = omap.GridSize(1) - goal(1);

%create a star planner and plan the route
planner = plannerAStarGrid(omap);
route = plan(planner,start,goal);
show(planner)

%untransform back to world coords
route(:, 1) = omap.GridSize(1) - route(:, 1);
route = route - omap.GridSize/2;
route = flip(route, 2);