io = mavlinkio('common.xml', ...
            'SystemID', 2, 'ComponentID', 1, ...
            'ComponentType', 'MAV_TYPE_QUADROTOR', ...
            'AutopilotType', 'MAV_AUTOPILOT_GENERIC');
io.connect("UDP");
a = mavlinksub(io, 'BufferSize', 10, 'NewMessageFcn', @(~, msg) disp("A: " + msg.SystemID));            

heartbeatmsg = io.Dialect.createmsg('HEARTBEAT');
heartbeatmsg.Payload.autopilot(:) = uint8(io.Dialect.enum2num('MAV_AUTOPILOT', 'MAV_AUTOPILOT_GENERIC'));
heartbeatmsg.Payload.type(:) = uint8(io.Dialect.enum2num('MAV_TYPE', 'MAV_TYPE_QUADROTOR'));
heartbeatmsg.Payload.system_status(:) = uint8(io.Dialect.enum2num('MAV_STATE', 'MAV_STATE_ACTIVE'));
heartbeatmsg.Payload.base_mode(:) = uint8(bitor(io.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_GUIDED_ENABLED'),  ...
    io.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_SAFETY_ARMED'))) ;

Heartbeat = timer;
Heartbeat.ExecutionMode = 'fixedRate';
Heartbeat.Period = 2;
Heartbeat.StartDelay = 0;
Heartbeat.TimerFcn = (@(~,~) heart(io, heartbeatmsg));

start(Heartbeat);
msg = dialect.createmsg('MISSION_COUNT');
            msg.Payload.target_system(:) = 1;
            msg.Payload.target_component(:) = 1;
            msg.Payload.count(:) = length(obj.Drone.waypoints);
            msg.Payload.mission_type(:) = enum2num(dialect, 'MAV_MISSION_TYPE',"MAV_MISSION_TYPE_MISSION");
            obj.IO.sendmsg(msg);

io.sendmsg(request);

pause(40);
delete(a);
delete(b);
stop(Heartbeat);
delete(Heartbeat); 
io.disconnect();

function heart(a, b)
    listTopics(a)
    sendudpmsg(a,b, '127.0.0.1', 14550);
end
