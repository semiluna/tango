io = mavlinkio('common.xml', ...
            'SystemID', 255, 'ComponentID', 0, ...
            'ComponentType', 'MAV_TYPE_GCS', ...
            'AutopilotType', 'MAV_AUTOPILOT_INVALID');
io.connect("UDP", 'LocalPort', 14550);
a = mavlinksub(io, 'BufferSize', 10, 'NewMessageFcn', @(~, msg) disp("A: " + msg.SystemID));            

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

% while(height(listClients(io)) < 2) 
% end
pause(7);

delete(a);
stop(Heartbeat);
delete(Heartbeat);
io.disconnect();

function sendfunc(a, b)
    disp("Sending");
    listClients(a)
    client = mavlinkclient(a, 2, 1);
    if(~ isempty(client))
    a.sendmsg(b);
    end
end