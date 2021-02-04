classdef MAVLinkInterface < matlab.System & matlab.system.mixin.Propagates
    %MAVLINKINTERFACE
    
    properties(Nontunable)
        GCSPort = 14550
        MaxMissionLength = 42
        homeLatitude = 41.8856528
        homeLongitude = -87.6556726
    end
    
    properties(Access = private)
        IO
        
        MissionProtocol
        
        Heartbeat
        
        Mission = struct('mode', uint8(0), ...
            'position', single([0 0 0]'), ...
            'params', single([0 0 0 0]'));
        
    end
    
    
    methods(Access = protected)
        function [missionItems, missionCount, uploadComplete] = stepImpl(obj, UAVState)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            
            persistent txSlot
            
            if isempty(txSlot)
                txSlot = uint8(0);
            end
            
            missionCount = obj.MissionProtocol.UAVMission.Count;
            
            uploadComplete = obj.MissionProtocol.UAVMission.UploadComplete;
            
            
            if uploadComplete == true
                receivedMission = obj.MissionProtocol.UAVMission.getMission;
                for ii = 1:missionCount
                    obj.Mission(ii,1) = receivedMission(ii);
                end
                
                % reset for next Cycle
                obj.MissionProtocol.UAVMission.UploadComplete = false;
            end
            
            missionItems = obj.Mission;
            
            switch txSlot
                case 0
                    attitudeMsg = obj.IO.Dialect.createmsg('ATTITUDE');
                    attitudeMsg.Payload.roll (:) = UAVState.attitude.roll;
                    attitudeMsg.Payload.pitch(:) = UAVState.attitude.pitch;
                    attitudeMsg.Payload.yaw(:) = UAVState.attitude.yaw;
                    attitudeMsg.Payload.rollspeed(:) = UAVState.attitude.rollspeed_p;
                    attitudeMsg.Payload.pitchspeed(:) = UAVState.attitude.pitchspeed_q;
                    attitudeMsg.Payload.yawspeed(:) = UAVState.attitude.yawspeed_r;
                    
                    sendudpmsg(obj.IO,attitudeMsg,'127.0.0.1',obj.GCSPort);
                    
                case 1
                    gpsRawIntMsg = obj.IO.Dialect.createmsg('GPS_RAW_INT');
                    gpsRawIntMsg.Payload.fix_type = uint8(enum2num(obj.IO.Dialect,'GPS_FIX_TYPE',"GPS_FIX_TYPE_3D_FIX"));
                    %gpsRawIntMsg.Payload.time_usec = UAVState.gps.time_usec;
                    gpsRawIntMsg.Payload.lat(:) = int32(UAVState.gps.lat);
                    gpsRawIntMsg.Payload.lon(:) = int32(UAVState.gps.lon);
                    gpsRawIntMsg.Payload.alt(:) = int32(UAVState.gps.alt);
                    gpsRawIntMsg.Payload.eph(:) = uint16(UAVState.gps.eph);
                    gpsRawIntMsg.Payload.epv(:) = uint16(UAVState.gps.epv);
                    gpsRawIntMsg.Payload.vel(:) = uint16(UAVState.gps.vel);
                    gpsRawIntMsg.Payload.cog(:) = uint16(UAVState.gps.cog);
                    
                    sendudpmsg(obj.IO, gpsRawIntMsg,'127.0.0.1',obj.GCSPort);
                    
                case 3
                    vfrHudMsg = obj.IO.Dialect.createmsg('VFR_HUD');
                    vfrHudMsg.Payload.airspeed(:) = UAVState.gps.vel/100;
                    vfrHudMsg.Payload.groundspeed(:) = UAVState.gps.vel/100;
                    vfrHudMsg.Payload.heading(:) = UAVState.attitude.yaw*180/pi;
                    vfrHudMsg.Payload.airspeed(:) = UAVState.gps.alt/1000;
                    
                    sendudpmsg(obj.IO, vfrHudMsg,'127.0.0.1',obj.GCSPort);
                    
            end
            
            
            % Reset the transmission slot designator
            if txSlot < 9
                txSlot = txSlot +1;
            else
                txSlot =0;
            end
            
        end
        
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.IO = mavlinkio('common.xml', 2, ...
                'SystemID', 1, 'ComponentID', 1, ...
                'AutopilotType', 'MAV_AUTOPILOT_GENERIC', ...
                'ComponentType', 'MAV_TYPE_QUADROTOR');
            obj.IO.connect("UDP");
            obj.MissionProtocol = exampleHelperMAVMissionProtocol(obj.IO);
            
            heartbeatmsg = obj.IO.Dialect.createmsg('HEARTBEAT');
            heartbeatmsg.Payload.autopilot(:) = uint8(obj.IO.Dialect.enum2num('MAV_AUTOPILOT', 'MAV_AUTOPILOT_SLUGS'));
            heartbeatmsg.Payload.type(:) = uint8(obj.IO.Dialect.enum2num('MAV_TYPE', 'MAV_TYPE_QUADROTOR'));
            heartbeatmsg.Payload.system_status(:) = uint8(obj.IO.Dialect.enum2num('MAV_STATE', 'MAV_STATE_ACTIVE'));
            heartbeatmsg.Payload.base_mode(:) = uint8(bitor(obj.IO.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_GUIDED_ENABLED'),  ...
                obj.IO.Dialect.enum2num('MAV_MODE_FLAG', 'MAV_MODE_FLAG_SAFETY_ARMED'))) ;
            
            obj.Heartbeat = timer;
            obj.Heartbeat.ExecutionMode = 'fixedRate';
            obj.Heartbeat.Period = 2;
            obj.Heartbeat.StartDelay = 0;
            obj.Heartbeat.TimerFcn = @(~,~)sendudpmsg(obj.IO,heartbeatmsg,'127.0.0.1',obj.GCSPort);
            start(obj.Heartbeat);
            
            for ii = 1:obj.MaxMissionLength
                obj.Mission(ii,1) = struct('mode', uint8(0), ...
                    'position', single([0 0 0]'), ...
                    'params', single([0 0 0 0]'));
            end
            
            % Send the Home Position upon Startup
            homePositionMsg = obj.IO.Dialect.createmsg('HOME_POSITION');
            homePositionMsg.Payload.latitude(:) = int32(obj.homeLatitude*1e7);
            homePositionMsg.Payload.longitude(:) = int32(obj.homeLongitude*1e7);
            homePositionMsg.Payload.altitude(:) = int32(0);
            sendudpmsg(obj.IO,homePositionMsg,'127.0.0.1',obj.GCSPort);
            
        end
        
        function releaseImpl(obj)
            % Release resources, such as file handles
            stop(obj.Heartbeat);
            obj.IO.disconnect();
        end
        
        function [missionItems, missionCount, uploadComplete] = getOutputSizeImpl(obj)
            % Return size for each output port
            missionItems = [obj.MaxMissionLength,1];
            missionCount = [1 1];
            uploadComplete = [1 1];
        end
        
        function [missionItems, missionCount, uploadComplete] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            missionItems = "uavPathManagerBus";
            missionCount = "uint16";
            uploadComplete = "logical";
        end
        
        function [missionItems, missionCount, uploadComplete] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            missionItems = false;
            missionCount = false;
            uploadComplete = false;
        end
        
        function [missionItems, missionCount, uploadComplete] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            missionItems = true;
            missionCount = true;
            uploadComplete = true;
        end
        
        
    end
    
    methods(Access = protected, Static)
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = "Interpreted execution";
        end
    end
end

