% result aggregation

for i = 1:config.new_user_number
    % result of interests
    label = result_table.label(i);
    frr = result_table.frr(i);

    % false positive (gallery user spoofing)
    far_gallery = mean(enroll_analysis_table.enroll_intruder_bit_err{i}<=config.bch_t);

    % false positive (new user spoofing)
    far_new_pool = [];
    for j = 1:config.new_user_number
        if j == i
            continue;
        end

        spoof_ud = table2struct(user_data_auth_ud(j,:));
        legitimate_saved_ud = table2struct(user_data_enrolled_ud(i,:));
        assert(spoof_ud.label~=legitimate_saved_ud.label,"Must use different user to simulate spoofing!");

        legitimate_analysis_data = enroll_analysis_table(i,:);
        assert(legitimate_analysis_data.label==legitimate_saved_ud.label, "Legitimate data must match!")

        % launch spoofing attack
        spoof_ud.label = legitimate_saved_ud.label;
        spoofed_ud2ae = main_auth_ud(spoof_ud, legitimate_saved_ud, config);

        spoofed_bit_err = sum(xor(spoofed_ud2ae.hashcode, legitimate_analysis_data.enroll_hashcode),2);
        single_frr_new = mean(spoofed_bit_err<=config.bch_t);

        far_new_pool = [far_new_pool;single_frr_new];
    end
    far_new = mean(far_new_pool);

    % hashcode_guessing (random)

    % hashcode_guessing (self)


    % save aggregation result
    idx = find(label_agg==label,1);

    if isempty(idx)
        label_agg = [label_agg,label];
        frr_agg = [frr_agg;frr];
        far_gallery_agg = [far_gallery_agg;far_gallery];
        far_new_agg = [far_new_agg;far_new];
        count_agg = [count_agg;1];
    else
        count_agg(idx) = count_agg(idx) + 1;
        frr_agg(idx) = (frr_agg(idx) + frr) ;
        far_gallery_agg(idx) = (far_gallery_agg(idx) + far_gallery) ;
        far_new_agg(idx) = (far_new_agg(idx) + far_new) ;
    end
end


