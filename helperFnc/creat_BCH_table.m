% 定义更强的BCH码参数
n = [63;  63;  127; 127; 255; 255];
k = [36;  30;  64;  50; 131; 123];
t = [13;  16;  31; 38; 62; 66];
tn_ratio = t ./ n;
num = [1:length(n)]';

% 创建table
bch_table = table(num, n, k, t, tn_ratio);

% 显示查找表
disp(bch_table);

% 保存查找表到.mat文件
save('bch_lookup_table.mat', 'bch_table');

% 显示保存成功的信息
disp('查找表已保存到bch_lookup_table.mat');
