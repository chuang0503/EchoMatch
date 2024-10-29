function giniIndex = calculateGiniIndex(wealth)
    % wealth: 一个包含每个用户财产的向量
    % 返回Gini指数

    n = numel(wealth); % 用户数量
    meanWealth = mean(wealth); % 平均财产

    % 计算所有用户两两之间的差值之和
    absDiffSum = 0;
    for i = 1:n
        for j = 1:n
            absDiffSum = absDiffSum + abs(wealth(i) - wealth(j));
        end
    end

    % 根据Gini指数公式进行计算
    giniIndex = absDiffSum / (2 * n^2 * meanWealth);
end

% 示例使用方法
% wealth = [10, 20, 30, 40, 50]; % 示例财产分布
% giniIndex = calculateGiniIndex(wealth);
% disp(['Gini指数: ', num2str(giniIndex)]);
