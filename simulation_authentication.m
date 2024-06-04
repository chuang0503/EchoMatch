% simulation authentication
addpath("helperFnc\")
addpath("main\")
%%
new_user_auth_ud = new_user.cross_auth_ud;

new_user_auth_ae = [];

for i = 1:config.new_user_number
    
    single_user_data = table2struct(new_user_auth_ud(i,:));
    % find stored ud data
    user_id = find(new_user_enroll_ae.label == single_user_data.label);
    stored_data = table2struct(new_user_enroll_ae(user_id,:));
    % concate data
    single_user_data.randmatrix = stored_data.randmatrix;
    single_user_data.feature_mask = stored_data.feature_mask;

    % auth ud
    single_user_auth_ud = main_auth_ud(single_user_data,config);

    % auth ae
    decision = main_auth_ae(single_user_auth_ud, ...
        new_user_enroll_ae, config);

    % record performance
    single_auth = struct();
    single_auth.label = single_user_data.label;
    single_auth.hashcode_new = single_user_auth_ud.hashcode;
    single_auth.frr = mean(decision);
    new_user_auth_ae = [new_user_auth_ae;single_auth];
end
new_user_auth_ae = struct2table(new_user_auth_ae);