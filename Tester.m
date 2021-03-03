
control = GroundControl;
waypoints = [
    41.8839798 -87.6569366 50;
    41.884243 -87.6569138 15;
    41.8845825 -87.6566 15;
    41.884243 -87.6569138 7;
    41.884243 -87.6569138 9;
    41.8839798 -87.6569366 15;
    41.8845787 -87.6558151 0
    ];


while(~control.sendWaypoints(waypoints))
end
time = clock;
for i = 1:10
    pause(1);
    pos = control.getPosition();
end

pause(50);
control.delete();

