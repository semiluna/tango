% Get omap

if ~exist('omap', 'var')
    disp("Omapping")
    omap = createOccupancyMap();
end
disp("got omap")




% Example 1 Preparation

start = [300,-300];
goal = [-500,0];

% Get route vector
route = computeRRTStarRoute(start, goal, false);

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong");

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong");

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route(:,[1,2]));
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)))




% Example 2 Preparation

start = [-410,210];
goal = [150,150];

% Get route vector
route = computeRRTStarRoute(start, goal, false);

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong");

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong");

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route(:,[1,2]));
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)))



% Example 3 Preparation

start = [-250,-250];
goal = [500,-300];

% Get route vector
route = computeRRTStarRoute(start, goal, false);

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong");

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong");

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route(:,[1,2]));
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)));



% Example 4 Preparation

start = [-250,-250];
goal = [130,-170];

% Get route vector
route = computeRRTStarRoute(start, goal, false);

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong");

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong");

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route(:,[1,2]));
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)));



% Example 5 Preparation

start = [-250,-250];
goal = [440,-150];

% Get route vector
route = computeRRTStarRoute(start, goal, false);

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong");

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong");

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route(:,[1,2]));
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)));



% Example 6 Preparation

start = [60,-265];
goal = [35,-262];

% Get route vector
route = computeRRTStarRoute(start, goal, false);

% Test 1: Start is correct

assert(isequal(route(1,1:2),start), "Start is wrong");

% Test 2: Goal is correct

assert(isequal(int32(route(end,1:2)),goal), "Goal is wrong");

% Test 3: Check if points along the route are in buildings

occupancy = getOccupancy(omap,route(:,[1,2]));
sz = size(occupancy);
assert(isequal(occupancy,zeros(sz)));



% Tests for Error Codes

%Inside Building

InsideBuilding1 = [100,-200];
known_outside = [100,200];

route = computeRRTStarRoute(InsideBuilding1, known_outside, false, false);

assert(route == -1)

InsideBuilding2 = [-150,150];
known_outside = [100,200];

route = computeRRTStarRoute(InsideBuilding2, known_outside, false, false);

assert(route == -1)

InsideBuilding3 = [0,0];
known_outside = [100,200];

route = computeRRTStarRoute(InsideBuilding3, known_outside, false, false);

assert(route == -1)

% No Path

start = [-555,65];
goal = [-556,30];

route = computeRRTStarRoute(start, goal, false, false);

assert(route == -2)

% Outside Wall

start = [0,-500];
goal = [35,-262];

route = computeRRTStarRoute(start, goal, false, false);

assert(route == -3)