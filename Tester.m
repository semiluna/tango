
control = GroundControl;
waypoints = [
    41.8839798 -87.6569366 50;
    41.884243 -87.6569138 15;
    41.8845787 -87.6558151 0
    ];


while(~control.sendWaypoints(waypoints))
end

for i = 1:10
    pause(1);
    control.isDroneIdle()
end
waypoints = [
    41.8845787 -87.6558151 30
    41.8839798 -87.6569366 50;
    41.884243 -87.6569138 15;
    41.8845825 -87.6566 15;
    41.884243 -87.6569138 7;
    41.884243 -87.6569138 9;
    41.8839798 -87.6569366 0;
    ];
while(~control.isDroneIdle())
    pause(1);
end
while(~control.sendWaypoints(waypoints))
end
pause(10);
control.delete();

