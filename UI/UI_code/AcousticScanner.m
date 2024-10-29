% urgent: <place_holder>
% option: EarCanalPlay needs resample before play when needed.

classdef AcousticScanner
    properties(Access = public)
        apr
        volume
        scan_signal_type
        scan_enroll_number
        scan_auth_number
        data_buffer
        test_audio_file = "audio/notification/leftright_48k.wav";
    end

    methods
        % Constructor method
        function obj = AcousticScanner(device)
            if nargin > 0
                obj.apr = device;
            else
                obj.apr = audioPlayerRecorder;
                obj.volume = -10;
            end
        end

        % Method to initinate audio device
        function obj = initDevice(obj, params)
            obj.volume = params.volume;
            obj.data_buffer = struct();
            obj.data_buffer.status = "empty";
            obj.data_buffer.data = [];
            obj.scan_signal_type = params.scan_signal_type;
            obj.scan_enroll_number = params.scan_enroll_number;
            obj.scan_auth_number = params.scan_auth_number;

            obj.apr.Device = params.Device;
            obj.apr.SampleRate = params.SampleRate;
            obj.apr.BitDepth = params.BitDepth;
            % obj.apr.BufferSize = params.BufferSize;
            eval("obj.apr.PlayerChannelMapping="+params.PlayerChannelMapping_str+";");
            eval("obj.apr.RecorderChannelMapping="+params.RecorderChannelMapping_str+";");

        end

        % Method to test audio device
        function status_success = testDevice(obj)
            [~,status_success] = EarCanalPlay(obj.apr, obj.test_audio_file, obj.volume);
        end

        % Method to scan for enrollment/authentication
        function obj = scanEarIR(obj, enroll_auth)
            % scan number * left/right
            if enroll_auth == "enroll"
                scan_number = obj.scan_enroll_number;
            elseif enroll_auth == "auth"
                scan_number = obj.scan_auth_number;
            else
                scan_number = 0;
            end

            scan_channel_num = length(obj.apr.RecorderChannelMapping);
            ir_batch = cell(scan_number, scan_channel_num);
            for i = 1:scan_number
                [ir_single_scan,status_success] = EarCanalScan(obj.apr, obj.scan_signal_type, obj.volume);
                if status_success
                    for j = 1:scan_channel_num
                        % left and right channel
                        ir_batch{i,j} = ir_single_scan(:,j);
                    end
                else
                    ir_batch = {};
                    break;
                end
            end

            if status_success
                obj.data_buffer.status = enroll_auth;
                obj.data_buffer.data = ir_batch;
            else
                obj.data_buffer.status = "empty";
                obj.data_buffer.data = {};
            end
        end

        function obj = clearBuffer(obj)
            obj.data_buffer.status = "empty";
            obj.data_buffer.data = {};
        end

    end
end