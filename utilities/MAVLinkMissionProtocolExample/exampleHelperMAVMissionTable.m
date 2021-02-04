classdef exampleHelperMAVMissionTable < handle
    %exampleHelperMAVParamTable stores parameters used in an UAV
    %   Parameters are stored according to MAVLink parameter definitions
    
    % Copyright 2019 The MathWorks, Inc.
    
    properties (Constant)

        
    end
    
    properties
        %Mission a map between Waypoint_ID and a struct of MISSION_ITEM_INT
        Mission
        
        %Count number of missionItems
        Count = uint16(0)
        
        % UploadComplete
        UploadComplete
    end
    
    methods
        
        function obj = exampleHelperMAVMissionTable()
            %Construct an empty parameter table
            obj.Mission = containers.Map('KeyType', 'double', 'ValueType', 'any');
                        
            obj.UploadComplete = false;
        end
        
        
        function insertMissionItem(obj, msgExt)
            %insert Add new item to the table expressed as a struct
            
            missionCommand = msgExt.Payload.command;
            missionP1 = msgExt.Payload.param1;
            missionP2 = msgExt.Payload.param2;
            missionP3 = msgExt.Payload.param3;
            missionP4 = msgExt.Payload.param4;
            missionX = msgExt.Payload.x;
            missionY = msgExt.Payload.y;
            missionZ = msgExt.Payload.z;            
            
            obj.Mission(uint16(msgExt.Payload.seq)) = ...
                struct('mode', uint8(missionCommand), ...
                'position', single([missionX; missionY; missionZ]), ...
                'params', single([missionP1; missionP2; missionP3; missionP4]));
        end
        
        function tbl = getTable(obj)
            %getTable returns all parameters in table format
            seq = zeros(size(obj.Mission));
            mode = zeros(size(obj.Mission));
            position = zeros([size(obj.Mission,1) 3]);
            params = zeros([size(obj.Mission,1) 4]);
            
            values = obj.Mission.values;
            for idx = 1:size(obj.Mission,1)
                value = values{idx};
                seq(idx) = idx;
                mode(idx) = value.mode;
                position(idx,:) = value.position;
                params(idx,:) = value.params;
            end
            
            tbl = table(seq, mode, position, params, 'VariableNames', {'Sequence', 'Command', 'Position', 'Params'});
        end
        
        function mission = getMission(obj)
            
            mission(size(obj.Mission,1), 1)  = struct('mode', uint8(0), ...
                'position', single([0; 0; 0]), ...
                'params', single([0; 0; 0; 0]));
            
            values = obj.Mission.values;
                        
            for idx = 1:size(obj.Mission,1)
                mission(idx) = values{idx};
            end
           
        end
    end
end

