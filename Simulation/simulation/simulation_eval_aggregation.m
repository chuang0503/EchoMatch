%% result aggregation
%-------------------- varaiables to aggregate---------------------------
% agg_analysis_table
    
% ----------------------------------------------------------------------

% test on each new user
for i = 1:config.new_user_number
    % read
    newRow = enroll_analysis_table(i,:);
    newRow = renamevars(newRow,{'enroll_bioinfo','enroll_legit_bit_err','enroll_intruder_bit_err'}, {'bioinfo','legit_enroll_bit_err','intruder_feat_bit_err'});
    assert(newRow.label==result_table.label(i),"User doesn't match!")
    newHashcode = result_table.hashcode{i};

    % calculate legitimate_auth_bit_err / intruder_code_bit_err
    legitimate_auth_bit_err = sum(xor(newRow.enroll_hashcode, newHashcode),2);
    intruder_code_bit_err = sum(xor(newRow.enroll_hashcode, enroll_analysis_table.enroll_hashcode([1:i-1,i+1:end],:)),2);

    % label
    lb = newRow.label;
    idx = find(agg_analysis_table.label==lb,1);
    newRow.enroll_pdf = [];
    newRow.enroll_hashcode = [];
    newRow.count = 1;
    newRow.legit_auth_bit_err = {legitimate_auth_bit_err};
    newRow.intruder_code_bit_err = {intruder_code_bit_err};

    if isempty(idx)
        agg_analysis_table = vertcat(agg_analysis_table, newRow);
    else
        agg_analysis_table.count(idx) = agg_analysis_table.count(idx) + 1;
        agg_analysis_table.bioinfo(idx) = agg_analysis_table.bioinfo(idx) + newRow.bioinfo;
        agg_analysis_table.legit_enroll_bit_err{idx} = vertcat(agg_analysis_table.legit_enroll_bit_err{idx},newRow.legit_enroll_bit_err{1});
        agg_analysis_table.legit_auth_bit_err{idx} = vertcat(agg_analysis_table.legit_auth_bit_err{idx},newRow.legit_auth_bit_err{1});
        agg_analysis_table.intruder_feat_bit_err{idx} = vertcat(agg_analysis_table.intruder_feat_bit_err{idx},newRow.intruder_feat_bit_err{1});
        agg_analysis_table.intruder_code_bit_err{idx} = vertcat(agg_analysis_table.intruder_code_bit_err{idx},newRow.intruder_code_bit_err{1});
    end
end

clear newRow intruder_code_bit_err lb idx


