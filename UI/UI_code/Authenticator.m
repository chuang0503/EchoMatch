% addpath preCalculate/ helperFnc/
% params.frequency_range_low = 1000;
% params.frequency_range_high = 8000;
% params.first_k_cepstrum = 256;
% params.renyi_alpha = 0;
% params.bch_n = 63;
% params.bch_k = 36;
% params.bch_t = 5;

classdef Authenticator
    properties
        % config
        config % struct
        % gallery
        gallery_data
        % data storage
        enrollment_user_list % string array
        enrollment_database % struct array
        % status
        auth_status
    end

    methods
        function obj = Authenticator(params)
            obj.auth_status = "";
            obj.enrollment_user_list = string([]);
            % obj.enrollment_database = [];
            obj.enrollment_database = struct('UserName', {}, 'Key', {}, 'Commitment', {}, 'RandMat', {}, 'FeatMask', {});
            %
            s = load("fp_setup.mat");
            obj.config.freqVec = s.freqVec;
            obj.config.Nfft = s.Nfft;
            obj.config.fs = s.fs;
            obj.gallery_data = s.gallery_data;
            %
            obj.config.frequency_range_low = params.frequency_range_low;
            obj.config.frequency_range_high = params.frequency_range_high;
            obj.config.first_k_cepstrum = params.first_k_cepstrum;
            obj.config.renyi_alpha = params.renyi_alpha;
            %
            obj.config.bch_n = params.bch_n;
            obj.config.bch_k = params.bch_k;
            obj.config.bch_t = params.bch_t;
            obj.config.ecc_code_size = obj.config.bch_n;
        end

        function obj = enrollUser(obj, user_name, fr_batch_cell)
            if any(strcmp(obj.enrollment_user_list,user_name))
                idx = find(strcmp(obj.enrollment_user_list, user_name),1);
                obj.auth_status = user_name + " is updating his/her enrolled data.";
            else
                idx = length(obj.enrollment_user_list) + 1;
                obj.enrollment_user_list(idx) = user_name;
                obj.auth_status = user_name + " is a new user. Enrolling.";
            end

            % convert to ceps feature (left ear)
            fr_batch = fr_batch_cell{1};

            %
            ceps_feature = helper_fft2ceps(fr_batch, obj.config.freqVec, ...
                obj.config.frequency_range_low , obj.config.frequency_range_high, ...
                obj.config.first_k_cepstrum);

            % normalize ceps feaeture
            feature = (ceps_feature - obj.gallery_data.stat_mean) ./ (obj.gallery_data.stat_std +eps);

            [pdf,~] = helper_pdfest(feature);

            % bioinformation mask
            [~, bmask] = helper_biofeatmask(pdf,obj.gallery_data.prob_density,obj.config.renyi_alpha);

            % biohashing
            [legit_hashcode, Q, ~] = helper_biohashing_enroll(feature.*bmask, obj.config.ecc_code_size);

            % fuzzy commitment
            [commitment, key] = helper_FC_enroll(legit_hashcode, obj.config.bch_n, obj.config.bch_k);

            % store to database
            userEnrollData = struct();
            userEnrollData.UserName = user_name;
            %
            userEnrollData.Key = key;
            userEnrollData.Commitment = commitment;
            %
            userEnrollData.RandMat = Q;
            userEnrollData.FeatMask = bmask;

            disp(userEnrollData);

            obj.enrollment_database(idx) = userEnrollData;
        end

        function obj = authUser(obj, current_user_name, fr_batch_cell)
            if any(obj.enrollment_user_list==current_user_name)
                idx = find(obj.enrollment_user_list==current_user_name,1);
            else
                obj.auth_status = current_user_name + " not found. Please enroll.";
                return
            end

            % retrieve data
            userEnrolledData = obj.enrollment_database(idx);

            % convert to ceps feature (left ear)
            fr_batch = fr_batch_cell{1};

            fft_feature = fr_batch;
            frequency_vector = obj.config.freqVec;
            randmatrix = userEnrolledData.RandMat;
            feature_mask = userEnrolledData.FeatMask;
            gallery_stat_mean = obj.gallery_data.stat_mean;
            gallery_stat_std = obj.gallery_data.stat_std;

            % pre-processing
            ceps_feature = helper_fft2ceps(fft_feature, frequency_vector, ...
                obj.config.frequency_range_low, obj.config.frequency_range_high, ...
                obj.config.first_k_cepstrum);

            % normalization
            feature = (ceps_feature - gallery_stat_mean) ./ (gallery_stat_std +eps);

            % Invariant feature vector + hashing
            current_hashcode = helper_biohashing_auth(feature .* feature_mask, randmatrix, obj.config.ecc_code_size);

            % compare with saved template
            trial_number = size(current_hashcode,1);
            bchDecoder = comm.BCHDecoder(obj.config.bch_n,obj.config.bch_k);

            saved_commitment = userEnrolledData.Commitment;
            saved_key = userEnrolledData.Key;

            % verify the user
            encoded_batch = xor(saved_commitment, current_hashcode);
            decoded_batch = zeros(trial_number,obj.config.bch_k);
            for i = 1:trial_number
                encoded_key = encoded_batch(i,:);
                [decoded_key, ~] = step(bchDecoder, encoded_key');
                decoded_batch(i,:) = decoded_key';
            end

            % ouput
            results = not(any((xor(decoded_batch,saved_key)),2));
            result_aggregate = sum(results)>(length(results)/2); % success


            if result_aggregate
                obj.auth_status = current_user_name + " successfully logged in!";
            else
                obj.auth_status = current_user_name + " authentication fails!";
            end
        end            


    end
end