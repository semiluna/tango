
control = GroundControl(@(~) pos(), @pos);
% waypoints = [
%     52.21037894063447 0.091505848407285276 10;
%     52.21143, 0.0894114 7;
%     52.21083, 0.0891007 5;
%     52.21128, 0.0873327 0;
%     ];
waypoints = [
    52.21034656661867, 0.09176126325723999, 10
     52.21039177874299, 0.08993557667267282, 10
    52.21104569472616, 0.09098192678993655, 10
    52.21102407508576,0.09214560505714076, 10
    52.21043251552607, 0.09261667155243458, 0
];


while(~control.sendWaypoints(waypoints))
end
pause(60);
waypoints = [
    52.21070947329772, 0.0916829041702556, 10;
    52.2105839855197, 0.09141860574823113, 10;
    52.21048742138968, 0.0916336036249561, 10;
    52.21047126958006, 0.09183336914713891, 10;
    52.210386007121166, 0.09154526938584695, 0; 
];
while(~control.sendWaypoints(waypoints))
end
pause(10);
control.delete();

function pos()
    
end

% while length(waypoints) < 20
%     difference = diff(waypoints);
%     distance_list = [];
%     for i = 1:(length(waypoints)-1)
%         distance_list = norm(difference(i, :));
%     end
%     [~, maxIdx] = max(distance_list);
%     newPoint = (waypoints(maxIdx, :) + waypoints(maxIdx+1, :))/2;
%     waypoints = [waypoints(1:maxIdx, :); newPoint; waypoints(maxIdx+1:end, :)];
% end
% 
% waypoints
% 


