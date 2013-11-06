classdef LibConfig < handle
    
    properties (Access = private)
        pCppObj = 0;
    end
    
    methods
        % Constructor
        function obj = LibConfig(configFile)
            obj.pCppObj = LibConfigMex('open',configFile);
        end
        
        % Destructor
        function delete(obj)
            if obj.pCppObj ~= 0
                LibConfigMex('close',obj.pCppObj);
            end
        end
        
        function result = readAll(obj)
            result = readNode(obj,'');
        end
        
        function result = readNode(obj,nodeName)
            result = struct;
            len = getLength(obj,nodeName);
            for i=0:len
                subNodeName = getSubSettingNameByIdx(obj,nodeName,i);
                if (~strcmp(subNodeName,''))
                    if (~strcmp(nodeName,''))
                        totalSubNodeName = [nodeName '.' subNodeName];
                    else
                        totalSubNodeName = subNodeName;
                    end
                    if (isGroup(obj,totalSubNodeName))
                        result.(subNodeName) = readNode(obj,totalSubNodeName);
                    else
                        result.(subNodeName) = get(obj,totalSubNodeName);
                    end
                end
            end
        end
        
        function val = get(varargin)
            obj = varargin{1};
            if obj.pCppObj ~= 0
                val = LibConfigMex('get',obj.pCppObj,varargin{2});
            end
        end
        
        function val = exists(varargin)
            obj = varargin{1};
            if obj.pCppObj ~= 0
                val = LibConfigMex('exists',obj.pCppObj,varargin{2});
            end
        end
        
        function val = isGroup(varargin)
            obj = varargin{1};
            if obj.pCppObj ~= 0
                val = LibConfigMex('isGroup',obj.pCppObj,varargin{2});
            end
        end
        
        function val = getLength(varargin)
            obj = varargin{1};
            if obj.pCppObj ~= 0
                val = LibConfigMex('getLength',obj.pCppObj,varargin{2});
            end
        end
        
        function val = getSubSettingNameByIdx(varargin)
            obj = varargin{1};
            if obj.pCppObj ~= 0
                val = LibConfigMex('getSubSettingNameByIdx',obj.pCppObj,varargin{2},varargin{3});
            end
        end
        
    end
end
