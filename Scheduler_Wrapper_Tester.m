format long

coord_map = containers.Map();
nodes = [];
distance_cache = zeros(300, 300);
gcDistance = zeros(1, 300);
mission_queue = [];
left = 1;
right = 1;

% Test 1: single mission scheduling works

start = WorldToLatLong([300,-300])
goal = WorldToLatLong([-500,0])

schedule = scheduler_wrapper([start;goal], coord_map, nodes, distance_cache, gcDistance, mission_queue, left, right)

nodes = schedule{1}
distance_cache = schedule{2};
gcDistance = schedule{3};
new_mission_queue = schedule{4}
left = schedule{5}
right = schedule{6}

assert(isequal(nodes,[WorldToLatLong([300,-300]);WorldToLatLong([-500,0])]))
assert(isequal(new_mission_queue,[1,2]))

% Test 2: multiple missions

start = WorldToLatLong([100,100])
goal = WorldToLatLong([400,200])

schedule = scheduler_wrapper([start;goal], coord_map, nodes, distance_cache, gcDistance, new_mission_queue, left, right)

nodes = schedule{1}
distance_cache = schedule{2};
gcDistance = schedule{3};
new_mission_queue = schedule{4}
left = schedule{5}
right = schedule{6}

assert(isequal(nodes,[WorldToLatLong([300,-300]);WorldToLatLong([-500,0]);WorldToLatLong([100,100]);WorldToLatLong([400,200])]))
assert(isequal(new_mission_queue,[1,2;3,4]))

% Test 3: same mission twice

coord_map = containers.Map();
nodes = [];
distance_cache = zeros(300, 300);
gcDistance = zeros(1, 300);
mission_queue = [];
left = 1;
right = 1;

start = WorldToLatLong([300,-300])
goal = WorldToLatLong([-500,0])

schedule = scheduler_wrapper([start;goal], coord_map, nodes, distance_cache, gcDistance, mission_queue, left, right)

nodes = schedule{1}
distance_cache = schedule{2};
gcDistance = schedule{3};
new_mission_queue = schedule{4}
left = schedule{5}
right = schedule{6}

start = WorldToLatLong([300,-300])
goal = WorldToLatLong([-500,0])

schedule = scheduler_wrapper([start;goal], coord_map, nodes, distance_cache, gcDistance, new_mission_queue, left, right)

nodes = schedule{1}
distance_cache = schedule{2};
gcDistance = schedule{3};
new_mission_queue = schedule{4}
left = schedule{5}
right = schedule{6}

assert(isequal(nodes,[WorldToLatLong([300,-300]);WorldToLatLong([-500,0])]))
assert(isequal(new_mission_queue,[1,2;1,2]))

% Test 4: mission and then reverse mission

coord_map = containers.Map();
nodes = [];
distance_cache = zeros(300, 300);
gcDistance = zeros(1, 300);
mission_queue = [];
left = 1;
right = 1;

start = WorldToLatLong([300,-300])
goal = WorldToLatLong([-500,0])

schedule = scheduler_wrapper([start;goal], coord_map, nodes, distance_cache, gcDistance, mission_queue, left, right)

nodes = schedule{1}
distance_cache = schedule{2};
gcDistance = schedule{3};
new_mission_queue = schedule{4}
left = schedule{5}
right = schedule{6}

start = WorldToLatLong([-500,0])
goal = WorldToLatLong([300,-300])

schedule = scheduler_wrapper([start;goal], coord_map, nodes, distance_cache, gcDistance, new_mission_queue, left, right)

nodes = schedule{1}
distance_cache = schedule{2};
gcDistance = schedule{3};
new_mission_queue = schedule{4}
left = schedule{5}
right = schedule{6}


assert(isequal(nodes,[WorldToLatLong([300,-300]);WorldToLatLong([-500,0])]))
assert(isequal(new_mission_queue,[1,2;2,1]))

