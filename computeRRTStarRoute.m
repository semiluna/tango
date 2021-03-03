function route = computeRRTStarRoute(start, goal)

%load occupancy map if not already defined
if ~exist('omap', 'var')
    omap = load("work/omap.mat").omap;
end

%translate input coords to world coords
start = LatLongToWorld(start);
goal = LatLongToWorld(goal);

%transform start and goal such that they are on the omap coord frame
start = start + omap.GridSize/2;
goal = goal + omap.GridSize/2;
start(3) = 0;
goal(3)=0;

%create the state space and validator, needed for the planner
ss = stateSpaceSE2;
ss.StateBounds = [omap.XWorldLimits; omap.YWorldLimits; [-pi pi]];
sv = validatorOccupancyMap(ss);
sv.Map = omap;
sv.ValidationDistance = 0.01;

%create rrt star planner and plan the route
planner = plannerRRTStar(ss, sv);
planner.ContinueAfterGoalReached = true;
planner.MaxIterations = 2000;
planner.MaxConnectionDistance =  30;

%plan the route
pthObj = plan(planner,start,goal);

%smooth the route, removing unnecassary waypoints
if pthObj.NumStates > 2
    pthObj = ExampleHelperUAVPathSmoothing(ss,sv,pthObj);
end

%show route on figure
 %omap.show;
 %hold on;
 %plot(pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2); % draw path

%untransform back to world coords
basicRoute = pthObj.States(:,1:2);
basicRoute = basicRoute - omap.GridSize/2;

%get the takeoff and landing z coords
startHeight = getHeight(basicRoute(1,1), basicRoute(1,2));
endHeight = getHeight(basicRoute(length(basicRoute),1), basicRoute(length(basicRoute),2));

%convert from world coords back to latlong
for i=1:length(basicRoute)
    latLong = WorldToLatLong([basicRoute(i,1), basicRoute(i,2)]);
    basicRoute(i,1) = latLong(1);
    basicRoute(i,2) = latLong(2);
end

%add z coords to all points and put into nx3 matrix
route = zeros(length(basicRoute)+2, 3);
route(1, :) = [basicRoute(1,1), basicRoute(1,2), startHeight];
for i =1:length(basicRoute)
   route(i+1, :) = [basicRoute(i,1), basicRoute(i,2), 35];
end
route(length(route), :) = [basicRoute(length(basicRoute),1), basicRoute(length(basicRoute), 2), endHeight];
