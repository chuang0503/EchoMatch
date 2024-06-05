% simulation authentication
addpath("helperFnc\")
addpath("main\")
%%
user_data_auth_ud = new_user.cross_auth_ud;
result_table = [];
for i = 1:config.new_user_number
    % authentication ud
    single_user_data_auth_ud = table2struct(user_data_auth_ud(i,:));
    single_user_data_enrolled_ud = table2struct(user_data_enrolled_ud(i,:));
    assert(single_user_data_auth_ud.label==single_user_data_enrolled_ud.label)
    
    single_user_data_auth_ud2ae = main_auth_ud(single_user_data_auth_ud, ...
        single_user_data_enrolled_ud, config);

   % authentication ae
    single_user_auth_decision = main_auth_ae(single_user_data_auth_ud2ae, ...
        user_data_enrolled_ae, config);

    % result
    result = struct();
    result.label = single_user_data_auth_ud.label;
    result.frr = mean(single_user_auth_decision);
    result_table = [result_table;result];

end
result_table = struct2table(result_table);

clear i single_user_data_auth_ud single_user_data_enrolled_ud 
clear single_user_data_auth_ud2ae single_user_auth_decision