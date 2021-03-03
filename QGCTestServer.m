io = mavlinkio('common.xml', ...
            'SystemID', 255, 'ComponentID', 0, ...
            'ComponentType', 'MAV_TYPE_GCS', ...
            'AutopilotType', 'MAV_AUTOPILOT_INVALID');
io.connect("UDP", 'LocalPort', 14550);
a = mavlinksub(io, 'MISSION_REQUEST_INT', 'BufferSize', 10, 'NewMessageFcn', @(~, ~) request(io));            

heartbeatmsg = io.Dialect.createmsg('HEARTBEAT');
heartbeatmsg.Payload.autopilot(:) = uint8(io.Dialect.enum2num('MAV_AUTOPILOT', 'MAV_AUTOPILOT_INVALID'));
heartbeatmsg.Payload.type(:) = uint8(io.Dialect.enum2num('MAV_TYPE', 'MAV_TYPE_GCS'));
heartbeatmsg.Payload.system_status(:) = uint8(io.Dialect.enum2num('MAV_STATE', 'MAV_STATE_ACTIVE'));
heartbeatmsg.Payload.base_mode(:) = uint8(bitor(io.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_GUIDED_ENABLED'),  ...
    io.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_SAFETY_ARMED'))) ;

Heartbeat = timer;
Heartbeat.ExecutionMode = 'fixedRate';
Heartbeat.Period = 2;
Heartbeat.StartDelay = 0;
Heartbeat.TimerFcn = (@(~,~) sendfunc(io, heartbeatmsg));

start(Heartbeat);

pause(30);

msg = io.Dialect.createmsg('MISSION_COUNT');
msg.Payload.target_system(:) = 1;
msg.Payload.target_component(:) = 1;
msg.Payload.count(:) = 4;
msg.Payload.mission_type(:) = enum2num(io.Dialect, 'MAV_MISSION_TYPE',"MAV_MISSION_TYPE_MISSION");
io.sendmsg(msg);
pause(30);
listTopics(io)
delete(a);
stop(Heartbeat);
delete(Heartbeat);
io.disconnect();

function request(a)
    msg = a.Dialect.createmsg('MISSION_ITEM_INT');
    msg.Payload.target_system(:) = 1;
    msg.Payload.target_component(:) = 1;
    msg.Payload.seq(:) = 0;
    msg.Payload.frame(:) = enum2num(a.Dialect,'MAV_FRAME',"MAV_FRAME_GLOBAL");
    a.sendmsg(msg);
end

function sendfunc(a, b)
    
    a.sendmsg(b);
end