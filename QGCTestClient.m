io = mavlinkio('common.xml', ...
            'SystemID', 2, 'ComponentID', 1, ...
            'ComponentType', 'MAV_TYPE_QUADROTOR', ...
            'AutopilotType', 'MAV_AUTOPILOT_GENERIC');
io.connect("UDP");
client = mavlinkclient(io, 255, 190);
a = mavlinksub(io, client, 'MISSION_ITEM_INT', 'BufferSize', 50,  'NewMessageFcn', @(~, msg) display_commands(msg));            

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
pause(50);
delete(a);
stop(Heartbeat);
delete(Heartbeat); 
io.disconnect();

function heart(a, b)
    sendudpmsg(a,b, '127.0.0.1', 14550);
end
function display_commands(msg)
    disp(msg);
end
