% simulation_data_split.m
% split the recorded data into gallery dataset/new users
%%
% addpath("helperFnc\")
%
load("echo_data.mat");
dataset_info = struct();

% validate two session data have same users
[userPool,~,~] = unique(s1.label);

% dataset info
dataset_info.total_user_number = length(userPool);
dataset_info.feature_dimension = size(s1.fft_raw,2);
dataset_info.frequency_vector = freqVec;
dataset_info.sampling_frequency = fs;
dataset_info.Nfft = Nfft;

assert(dataset_info.total_user_number >= config.gallery_user_number + ...
    config.new_user_number, "Cannot split dataset: insuficient user!")

% shuffle
temp_id = randperm(dataset_info.total_user_number);
userPool_shuffled = userPool(temp_id);

%% randomly generate gallery data
gallery_data = struct();
gallery_data.userPool = userPool_shuffled(1:config.gallery_user_number);
gallery_data.fft_feature = [];
gallery_data.label = []; % used for performance evaluation only

% gallery data from session 1
for i=1:config.gallery_user_number
    selected_feature = s1.fft_raw(s1.label==gallery_data.userPool(i),:);
    gallery_data.fft_feature = [gallery_data.fft_feature; selected_feature];
    gallery_data.label = [gallery_data.label; repmat(gallery_data.userPool(i),size(selected_feature,1),1)];
end

% gallery data from session 2
for i=1:config.gallery_user_number
    selected_feature = s2.fft_raw(s2.label==gallery_data.userPool(i),:);
    gallery_data.fft_feature = [gallery_data.fft_feature; selected_feature];
    gallery_data.label = [gallery_data.label; repmat(gallery_data.userPool(i),size(selected_feature,1),1)];
end


gallery_data.feature = helper_fft2ceps(gallery_data.fft_feature, dataset_info.frequency_vector, ...
    config.frequency_range_low, config.frequency_range_high, config.first_K_cepstrum);

% Compute gallery data statistic
gallery_data.stat_mean = mean(gallery_data.feature);
gallery_data.stat_std = std(gallery_data.feature) + eps;

gallery_data.feature = (gallery_data.feature - gallery_data.stat_mean) ./ gallery_data.stat_std;

% estimate gallery data pdf
[gallery_data.prob_density, ~] = helper_pdfest(gallery_data.feature);

% clear temp data
clear fs i Nfft selected_feature temp_id
%% generate new user data
new_user.UserPool = userPool_shuffled(end-config.new_user_number+1:end);

% enroll data: must be captured before test data
new_user.user_data_enroll_ud = [];

for i=1:config.new_user_number

    user_idx = find(s1.label==new_user.UserPool(i));

    % enrollment batch (from session 1)
    enroll_idx = user_idx(1:config.new_user_enroll_size);
    fft_feature = s1.fft_raw(enroll_idx,:);
    
    % put into structure
    newUserData = struct();
    newUserData.label = new_user.UserPool(i);
    newUserData.fft_feature = fft_feature;
    newUserData.frequency_vector = freqVec;

    new_user.user_data_enroll_ud = [new_user.user_data_enroll_ud;newUserData];

end
new_user.user_data_enroll_ud = struct2table(new_user.user_data_enroll_ud);

clear fft_feature enroll_idx i newUserData user_idx

% authentication data: must be captured after enrollment
% cont_session authentication
new_user.cont_auth_ud = [];

for i=1:config.new_user_number

    newUserData = struct();
    newUserData.label = new_user.UserPool(i);

    user_idx = find(s1.label==new_user.UserPool(i));

    % enrollment batch (from session 1)
    auth_idx = user_idx(config.new_user_enroll_size+1:end);
    fft_feature = s1.fft_raw(auth_idx,:);

    newUserData.fft_feature = fft_feature;
    newUserData.frequency_vector = freqVec;


    new_user.cont_auth_ud = [new_user.cont_auth_ud;newUserData];

end
new_user.cont_auth_ud = struct2table(new_user.cont_auth_ud);

clear fft_feature auth_idx i newUserData user_idx

% cross_session authentication
new_user.cross_auth_ud = [];

for i=1:config.new_user_number

    newUserData = struct();
    newUserData.label = new_user.UserPool(i);

    user_idx = find(s2.label==new_user.UserPool(i));

    % enrollment batch (from session 1)
    auth_idx = user_idx;
    fft_feature = s2.fft_raw(auth_idx,:);

    newUserData.fft_feature = fft_feature;
    newUserData.frequency_vector = freqVec;

    new_user.cross_auth_ud = [new_user.cross_auth_ud;newUserData];

end
new_user.cross_auth_ud = struct2table(new_user.cross_auth_ud);

clear fft_feature auth_idx i newUserData user_idx

%% clear unused data
clear s1 s2 userPool_shuffled userPool freqVec
