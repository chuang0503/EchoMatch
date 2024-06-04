addpath("helperFnc\")
addpath("main\")

% enrollment
new_user_enroll_ae = [];
for i = 1:config.new_user_number
    single_user_data = table2struct(new_user.enroll_ud(i,:));

    single_user_enroll_ae = ...
        main_enroll_ae(single_user_data, gallery, config, "analysis");

    new_user_enroll_ae = [new_user_enroll_ae;single_user_enroll_ae];
end
new_user_enroll_ae = struct2table(new_user_enroll_ae);
clear i single_user_data single_user_enroll_ae

