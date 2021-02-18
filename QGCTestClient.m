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
client = mavlinkclient(io, 255, 0);


start(Heartbeat);


pause(15);
b = mavlinksub(io, 'BufferSize', 10, 'NewMessageFcn', @(~, msg) disp("B: " + msg.SystemID));
v = [41.8839798 -87.6569366 15];
pause(10);
% for i = 1:60
    
    
    
%     gpsRawIntMsg = io.Dialect.createmsg('GPS_RAW_INT');
%                     gpsRawIntMsg.Payload.fix_type = uint8(enum2num(io.Dialect,'GPS_FIX_TYPE',"GPS_FIX_TYPE_3D_FIX"));
%                     %gpsRawIntMsg.Payload.time_usec = UAVState.gps.time_usec;
%                     gpsRawIntMsg.Payload.lat(:) = int32(v(1)*10e7);
%                     gpsRawIntMsg.Payload.lon(:) = int32(v(2)*10e7);
%                     gpsRawIntMsg.Payload.alt(:) = int32(v(3));
%                     gpsRawIntMsg.Payload.eph(:) = uint16(80);
%                     gpsRawIntMsg.Payload.epv(:) = uint16(80);
%                     gpsRawIntMsg.Payload.vel(:) = uint16(72);
%                     gpsRawIntMsg.Payload.cog(:) = uint16(676);
%                     
%                    sendudpmsg(io, gpsRawIntMsg,'127.0.0.1',int32(str2double(info_con(end-4:end))));
% end
delete(a);
delete(b);
stop(Heartbeat);
delete(Heartbeat); 
io.disconnect();

function heart(a, b)
    disp("Heart");
    sendudpmsg(a,b, '127.0.0.1', 14550);
end


function send(io)
    dialect = io.Dialect;
    outMsg = dialect.createmsg('MISSION_ITEM_INT');

    outMsg.Payload.target_system = 255;
    outMsg.Payload.target_component = 0;
    
    io.sendmsg(outMsg);
end