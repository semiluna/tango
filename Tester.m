
control = GroundControl2;
waypoints = [
    41.8839798 -87.6569366 15;
    41.884243 -87.6569138 15;
    41.8845825 -87.6566 15;
    41.8845787 -87.6558151 0
    ];
heartbeatmsg = control.IO.Dialect.createmsg('HEARTBEAT');
    heartbeatmsg.Payload.autopilot(:) = uint8(control.IO.Dialect.enum2num('MAV_AUTOPILOT', 'MAV_AUTOPILOT_INVALID'));
    heartbeatmsg.Payload.type(:) = uint8(control.IO.Dialect.enum2num('MAV_TYPE', 'MAV_TYPE_GCS'));
    heartbeatmsg.Payload.system_status(:) = uint8(control.IO.Dialect.enum2num('MAV_STATE', 'MAV_STATE_ACTIVE'));
    heartbeatmsg.Payload.base_mode(:) = uint8(bitor(control.IO.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_GUIDED_ENABLED'),  ...
        control.IO.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_SAFETY_ARMED'))) ;

    Heartbeat = timer;
    Heartbeat.ExecutionMode = 'fixedRate';
    Heartbeat.Period = 2;
    Heartbeat.StartDelay = 0;
    Heartbeat.TimerFcn = @(~,~) control.IO.sendmsg(heartbeatmsg);
    % start(Heartbeat);

control.sendWaypoints(waypoints);
time = clock;
for i = 1:10
    pause(1);
    control.sendWaypoints(waypoints);
end
stop(Heartbeat);
control.delete();

