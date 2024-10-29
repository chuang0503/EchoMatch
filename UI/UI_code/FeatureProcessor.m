classdef FeatureProcessor
    properties
        % Properties with default values
        freqVec
        Nfft
        fs
        data_buffer
    end

    methods
        % Constructor method
        function obj = FeatureProcessor(freqVec, Nfft, fs)
            % Allow overriding defaults through constructor arguments
            if nargin > 0
                obj.freqVec = freqVec;
                obj.Nfft = Nfft;
                obj.fs = fs;
            else
                s = load("fp_setup.mat");
                obj.freqVec = s.freqVec;
                obj.Nfft = s.Nfft;
                obj.fs = s.fs;
            end

            obj.data_buffer.status = "empty";
            obj.data_buffer.data = {};
        end

        % ir to fr
        function fr_batch = ir2fr(obj, ir_batch)
            % check batch size and channel number
            [scan_num, channel_num] = size(ir_batch);

            fr_batch = cell(1, channel_num);

            for j = 1:channel_num
                fr_lateral = zeros(scan_num, obj.Nfft);
                for i = 1:scan_num
                    ir_single = ir_batch{i,j};
                    fr_single = freqz(ir_single, 1, obj.freqVec, obj.fs);
                    fr_single = abs(fr_single).^2;
                    fr_lateral(i,:) = fr_single;
                end

                fr_batch{j} = fr_lateral;
            end
        end

        function obj = saveData(fr_batch)

            channel_num = length(fr_batch);

            if channel_num<1
                obj.data_buffer.status = "empty";
                obj.data_buffer.data = {};
            elseif channel_num<2
                obj.data_buffer.status = "left";
                obj.data_buffer.data = fr_batch;
            elseif channel_num<3
                obj.data_buffer.status = "left/right";
                obj.data_buffer.data = fr_batch;
            else
                obj.data_buffer.status = "empty";
                obj.data_buffer.data = {};
            end

        end














    end
end