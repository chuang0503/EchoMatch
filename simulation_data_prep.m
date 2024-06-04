% simulation_data_split.m
% split the recorded data into gallery dataset/new users
%%
addpath("helperFnc\")
%
load("Data/echo_data.mat");
dataset_info = struct();

% validate two session data have same users
[userPool,~,~] = unique(s1.label);

% dataset info
dataset_info.total_user_number = length(userPool);
dataset_info.feature_dimension = size(s1.fft_raw,2);
dataset_info.frequency_vector = freqVec;
dataset_info.sampling_frequency = fs;
dataset_info.Nfft = Nfft;

assert(dataset_info.total_user_number > config.gallery_user_number + ...
    config.new_user_number, "Cannot split dataset: insuficient user!")

% shuffle
temp_id = randperm(dataset_info.total_user_number);
userPool_shuffled = userPool(temp_id);

%% randomly generate gallery data
gallery = struct();
gallery.userPool = userPool_shuffled(1:config.gallery_user_number);
gallery.fft_feature = [];
gallery.label = []; % used for performance evaluation only

% gallery data from session 1
for i=1:config.gallery_user_number
    selected_feature = s1.fft_raw(s1.label==gallery.userPool(i),:);
    gallery.fft_feature = [gallery.fft_feature; selected_feature];
    gallery.label = [gallery.label; repmat(gallery.userPool(i),size(selected_feature,1),1)];
end

% gallery data from session 2
for i=1:config.gallery_user_number
    selected_feature = s2.fft_raw(s2.label==gallery.userPool(i),:);
    gallery.fft_feature = [gallery.fft_feature; selected_feature];
    gallery.label = [gallery.label; repmat(gallery.userPool(i),size(selected_feature,1),1)];
end


gallery.ceps_feature = helper_fft2ceps(gallery.fft_feature, dataset_info.frequency_vector, ...
    config.frequency_range_low, config.frequency_range_high);
gallery.ceps_feature = gallery.ceps_feature(:,1:config.first_K_cepstrum);

% Compute gallery data statistic
gallery.stat_mean = mean(gallery.ceps_feature);
gallery.stat_std = std(gallery.ceps_feature) + eps;

gallery.ceps_feature = (gallery.ceps_feature - gallery.stat_mean) ./ gallery.stat_std;

% estimate gallery data pdf
[gallery.ceps_prob_density, ~] = helper_pdfest(gallery.ceps_feature);

% clear temp data
clear freqVec fs i Nfft selected_feature temp_id
%% generate new user data
new_user.UserPool = userPool_shuffled(end-config.new_user_number+1:end);

% enrolled data: must be captured before test data
new_user.enoll = [];

for i=1:config.new_user_number

    newUserData = struct();
    newUserData.label = new_user.UserPool(i);

    user_idx = find(s1.label==new_user.UserPool(i));

    % enrollment batch (from session 1)
    enroll_idx = user_idx(1:config.new_user_enroll_size);
    enroll_fft_feature = s1.fft_raw(enroll_idx,:);

    ceps = helper_fft2ceps(enroll_fft_feature,dataset_info.frequency_vector, ...
        config.frequency_range_low,config.frequency_range_high);
    ceps = ceps(:,1:config.first_K_cepstrum);

    newUserData.feature = (ceps - gallery.stat_mean) ./gallery.stat_std;

    [enroll_pdf,~] = helper_pdfest(newUserData.feature);
    newUserData.prob_density = enroll_pdf;

    new_user.enoll = [new_user.enoll;newUserData];

end
new_user.enoll = struct2table(new_user.enoll);

clear ceps enroll_fft_feature enroll_idx enroll_pdf i newUserData user_idx

% authentication data: must be captured after enrollment
% cont_session authentication
new_user.cont_auth = [];

for i=1:config.new_user_number

    newUserData = struct();
    newUserData.label = new_user.UserPool(i);

    user_idx = find(s1.label==new_user.UserPool(i));

    % enrollment batch (from session 1)
    auth_idx = user_idx(config.new_user_enroll_size+1:end);
    auth_fft_feature = s1.fft_raw(auth_idx,:);

    ceps = helper_fft2ceps(auth_fft_feature,dataset_info.frequency_vector, ...
        config.frequency_range_low,config.frequency_range_high);
    ceps = ceps(:,1:config.first_K_cepstrum);

    newUserData.feature = (ceps - gallery.stat_mean) ./gallery.stat_std;

    new_user.cont_auth = [new_user.cont_auth;newUserData];

end
new_user.cont_auth = struct2table(new_user.cont_auth);

clear ceps auth_fft_feature auth_idx i newUserData user_idx

% cross_session authentication
new_user.cross_auth = [];

for i=1:config.new_user_number

    newUserData = struct();
    newUserData.label = new_user.UserPool(i);

    user_idx = find(s2.label==new_user.UserPool(i));

    % enrollment batch (from session 1)
    auth_idx = user_idx;
    auth_fft_feature = s2.fft_raw(auth_idx,:);

    ceps = helper_fft2ceps(auth_fft_feature,dataset_info.frequency_vector, ...
        config.frequency_range_low,config.frequency_range_high);
    ceps = ceps(:,1:config.first_K_cepstrum);

    newUserData.feature = (ceps - gallery.stat_mean) ./gallery.stat_std;

    new_user.cross_auth = [new_user.cross_auth;newUserData];

end
new_user.cross_auth = struct2table(new_user.cross_auth);

clear ceps auth_fft_feature auth_idx i newUserData user_idx

%% clear unused data
clear s1 s2 userPool_shuffled userPool
