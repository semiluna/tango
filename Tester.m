
control = GroundControl(@(p) pos(p), @() disp('Landed'));
% waypoints = [
%     52.21037894063447 0.091505848407285276 10;
%     52.21143, 0.0894114 7;
%     52.21083, 0.0891007 5;
%     52.21128, 0.0873327 0;
%     ];

waypoints = [
    52.2113 0.0888247 10;
    52.21157 0.0891377 10;
    52.21127 0.0893901 10;
    52.21115 0.0895306 10;
    52.21101 0.088753 10;
    52.21127 0.0882007 0;
];

while(~control.sendWaypoints(waypoints))
end
pause(5);
for i = 1:10
    pause(3);
    % control.isDroneIdle()
end

pause(5);
control.delete();

function pos(position)
    pause(3);
    disp(position);
end

