
control = GroundControl(@(~) pos(), @pos);
% waypoints = [
%     52.21037894063447 0.091505848407285276 10;
%     52.21143, 0.0894114 7;
%     52.21083, 0.0891007 5;
%     52.21128, 0.0873327 0;
%     ];
waypoints = [
    52.21136414121557, 0.08872956575461899, 10
    52.21137959,0.08889783,10;
    52.21131021844225,0.08886994100640777,0;
];


while(~control.sendWaypoints(waypoints))
end
pause(30);
waypoints = [
    52.21131021844225,0.08886994100640777,10;
    52.21137959,0.08889783,5;
    52.21131021844225,0.08886994100640777,0;
];
while(~control.sendWaypoints(waypoints))
end
pause(10);
control.delete();

function pos()
    
end

