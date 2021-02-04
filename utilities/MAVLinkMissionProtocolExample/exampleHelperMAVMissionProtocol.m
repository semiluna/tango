classdef exampleHelperMAVMissionProtocol < handle
    % exampleHelperMAVMissionProtocol MAVLink Mission Protocol Implementation
    %   exampleHelperMAVMissionProtocol Handle class that stores methods and properties of
    % MAVLink's mission protocol
    %
    % Copyright 2018 The MathWorks, Inc.
    
    properties
        % UAVInfo stores drone information
        UAVInfo
        
        % UAVParameters stores drone parameters
        UAVMission
        
        %Message Subscribers for the Mission Protocol
        MissionCountSubscriber
        MissionItemIntSubscriber
        
    end
    
    methods
        function obj = exampleHelperMAVMissionProtocol(io)
            %exampleHelperMAVParamProtocol Contruct an instance of this class
            
            % Log drone information
            obj.UAVInfo = io.LocalClient;
            
            % Function to populate UAVParameters property with parameter table
            createMissionTable(obj, io);
            
            % Create subscriber to MISSION_COUNT
            % Used to initiate Mission uploading to a vehicle.
            obj.MissionCountSubscriber = mavlinksub(io, 'MISSION_COUNT', ...
                'BufferSize', 10, ...
                'NewMessageFcn', ...
                @(~,msgExt)exampleHelperMAVMissionProtocol.missionMissionCountCallback(msgExt, io, obj));

            
            % Create subscriber to MISSION_ITEM_INT
            % Used to receive a Mission item in a vehicle.
            obj.MissionItemIntSubscriber = mavlinksub(io, 'MISSION_ITEM_INT', ...
                'BufferSize', 60, ...
                'NewMessageFcn', ...
                @(~,msgExt)exampleHelperMAVMissionProtocol.missionMissionItemIntCallback(msgExt, io, obj));
            
        end
        
        function tbl = getMission(obj)
            %getMisson returns mission in table format
            tbl = obj.UAVMission.getTable();
        end
        
        function delete(obj)
            %delete all subscribers
            delete(obj.MissionCountSubscriber);
            delete(obj.MissionItemIntSubscriber);
            
        end
        
    end
    
    methods (Access=private)
        
        function createMissionTable(obj, io)
            %createTable populate a 4-waypoint Mission
            
            % assign UAVParameters property to a Parameter Table type
            obj.UAVMission = exampleHelperMAVMissionTable;
            
            insertMissionItem(obj.UAVMission, exampleHelperMAVMissionProtocol.createMissionItem(io, ...
                enum2num(io.Dialect,'MAV_CMD',"MAV_CMD_NAV_TAKEOFF"),...
                [42.3003992 ...
                -71.3751941 ...
                25.0000000], ...
                [0 0 0 0], 1));
            
            insertMissionItem(obj.UAVMission, exampleHelperMAVMissionProtocol.createMissionItem(io,...
                enum2num(io.Dialect,'MAV_CMD',"MAV_CMD_NAV_WAYPOINT"), ...
                [42.3015974  ...
                -71.3755160 ...
                25.0000000], ...
                [0 0 0 0], 2));
            
            insertMissionItem(obj.UAVMission, exampleHelperMAVMissionProtocol.createMissionItem(io,...
                enum2num(io.Dialect,'MAV_CMD',"MAV_CMD_NAV_WAYPOINT"), ...
                [42.3015895  ...
                -71.3766747 ...
                25.0000000], ...
                [0 0 0 0], 3));
            
           insertMissionItem(obj.UAVMission, exampleHelperMAVMissionProtocol.createMissionItem(io,...
                enum2num(io.Dialect,'MAV_CMD',"MAV_CMD_NAV_LAND"), ...
                [42.3003436  ...
                -71.3758700 ...
                0.0000000], ...
                [0 0 0 0], 4));
            
        end
    end
    
    methods (Static)
        
        function missionMissionCountCallback(msg, io, protocol)
            %missionMissionCountCallback gets called for every incoming MISSION_COUNT message
            
            if (msg.Payload.target_system == protocol.UAVInfo.SystemID) && ...
                    (msg.Payload.target_component == 0 ... 
                    || msg.Payload.target_component == protocol.UAVInfo.ComponentID)
                
                %set the protocol Count value
                protocol.UAVMission.Count = msg.Payload.count;
                
                % setup a dialect to send messsages
                dialect = io.Dialect;
                client = mavlinkclient(io, msg.SystemID, msg.ComponentID);
                
                
                % create a MISSION_REQUEST_INT for WP 1
                msgsend = dialect.createmsg('MISSION_REQUEST_INT');
                
                msgsend.Payload.target_system(:) = 255;
                msgsend.Payload.target_component(:) = 0;
                msgsend.Payload.seq(:) = 0;
                msgsend.Payload.mission_type = enum2num(dialect,'MAV_MISSION_TYPE',"MAV_MISSION_TYPE_MISSION");
                
                % send request for first WP
                io.sendmsg(msgsend, client)
                protocol.UAVMission.UploadComplete = false;
            end
        end
            
            
        function missionMissionItemIntCallback(msg, io, protocol)
            %missionMissionCountCallback gets called for every incoming MISSION_COUNT message
            
            if (msg.Payload.target_system == protocol.UAVInfo.SystemID) && ...
                    (msg.Payload.target_component == 0 || msg.Payload.target_component == protocol.UAVInfo.ComponentID)
                
                
                % setup a dialect to send messsages
                dialect = io.Dialect;
                client = mavlinkclient(io, msg.SystemID, msg.ComponentID);
                
                % store the received mission item
                insertMissionItem(protocol.UAVMission, exampleHelperMAVMissionProtocol.createMissionItem(io,...
                    msg.Payload.command, ...
                    [single(msg.Payload.x)/1e7  ...
                    single(msg.Payload.y)/1e7 ...
                    single(msg.Payload.z)], ...
                    [msg.Payload.param1 ...
                    msg.Payload.param2 ...
                    msg.Payload.param3 ...
                    msg.Payload.param4], ...
                    msg.Payload.seq));
                
                % if this is the last WP expected
                if msg.Payload.seq >= (protocol.UAVMission.Count -1)
                    % send an ack
                    msgsend = dialect.createmsg('MISSION_ACK');
                    
                    msgsend.Payload.target_system(:) = 255;
                    msgsend.Payload.target_component(:) = 0;
                    msgsend.Payload.type(:) =enum2num(dialect,'MAV_MISSION_RESULT',"MAV_MISSION_ACCEPTED");
                    msgsend.Payload.mission_type = enum2num(dialect,'MAV_MISSION_TYPE',"MAV_MISSION_TYPE_MISSION");
                    
                    io.sendmsg(msgsend, client)
                    protocol.UAVMission.UploadComplete = true;
                    
                else % otherwise request next WP
                    msgsend = dialect.createmsg('MISSION_REQUEST_INT');
                    
                    msgsend.Payload.target_system(:) = 255;
                    msgsend.Payload.target_component(:) = 0;
                    msgsend.Payload.seq(:) = msg.Payload.seq + 1;
                    msgsend.Payload.mission_type = enum2num(dialect,'MAV_MISSION_TYPE',"MAV_MISSION_TYPE_MISSION");
                    
                    io.sendmsg(msgsend, client)
                    protocol.UAVMission.UploadComplete = false;
                end
                
                
            end
        end
        
        function msg = createMissionItem(io, mode, position, params, count)
            %createParam create a new PARAM_VALUE message
            msg = io.Dialect.createmsg('PARAM_VALUE');
            
            % Modify message payload to create a parameter entry
            msg.Payload.seq(:) = count;
            msg.Payload.frame(:) = enum2num(io.Dialect,'MAV_FRAME',"MAV_FRAME_GLOBAL");
            msg.Payload.command(:) = mode;
            msg.Payload.current(:) = 0;
            msg.Payload.autocontinue(:) = 1;
            msg.Payload.param1(:) = params(1);
            msg.Payload.param2(:) = params(2);
            msg.Payload.param3(:) = params(3);
            msg.Payload.param4(:) = params(4);
            msg.Payload.x = position(1);
            msg.Payload.y = position(2);
            msg.Payload.z = position(3);
            msg.Payload.mission_type = enum2num(io.Dialect,'MAV_MISSION_TYPE',"MAV_MISSION_TYPE_MISSION");
        end
    end
end

