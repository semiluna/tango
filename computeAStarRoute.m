function route = computeAStarRoute(start, goal)

%create occupancy map if not already defined
if ~exist('omap', 'var')
    omap = createOccupancyMap();
end

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

show(omap)
%create rrt star planner and plan the route
planner = plannerRRTStar(ss, sv);
planner.ContinueAfterGoalReached = true;
planner.MaxIterations = 2500;
planner.MaxConnectionDistance =  5;

%plan the route
pthObj = plan(planner,start,goal);

%smooth the route, removing unnecassary waypoints
if pthObj.NumStates > 2
    pthObj = ExampleHelperUAVPathSmoothing(ss,sv,pthObj);
end
%show route on figure
% omap.show;
% hold on;
% plot(solnInfo.TreeData(:,1),solnInfo.TreeData(:,2), '.-'); % tree expansion
% plot(pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2); % draw path

%untransform back to world coords
route = pthObj.States(:,1:2);
route = route - omap.GridSize/2;