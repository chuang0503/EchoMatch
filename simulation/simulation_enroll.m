% addpath("helperFnc\")
% addpath("main\")

user_data_enroll_ud = new_user.user_data_enroll_ud;
user_data_enrolled_ae = [];
user_data_enrolled_ud = [];
enroll_analysis_table = [];
for i = 1:config.new_user_number
    % enrollment
    single_user_data_enroll_ud = table2struct(user_data_enroll_ud(i,:));
    single_user_data_enroll_ud2ae = main_enroll_ud(single_user_data_enroll_ud,config);

    [single_user_data_enrolled_ae, single_user_data_enrolled_ud, analysis] = ...
        main_enroll_ae(single_user_data_enroll_ud2ae, gallery_data, config);

    user_data_enrolled_ae = [user_data_enrolled_ae;single_user_data_enrolled_ae];
    user_data_enrolled_ud = [user_data_enrolled_ud;single_user_data_enrolled_ud];
    enroll_analysis_table = [enroll_analysis_table; analysis];

end
user_data_enrolled_ae = struct2table(user_data_enrolled_ae);
user_data_enrolled_ud = struct2table(user_data_enrolled_ud);
enroll_analysis_table = struct2table(enroll_analysis_table);


clear i single_user_data_enroll_ud single_user_data_enroll_ud2ae
clear single_user_data_enrolled_ae single_user_data_enrolled_ud
clear analysis