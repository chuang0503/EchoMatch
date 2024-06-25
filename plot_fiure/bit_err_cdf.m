figure(1);
[f1,x1] = ecdf(legit_auth_err);
[f2,x2] = ecdf(legit_enroll_err);
hold on;
plot(x1, f1, 'k-', 'LineWidth', 1.5, 'Marker', 'o', 'MarkerSize', 6); % 
plot(x2, f2, 'r--', 'LineWidth', 1.5, 'Marker', 's', 'MarkerSize', 6); % 
hold off;
legend("Legit Auth", "Legit Enroll")
%
xlim([0 10]);xlabel("Ear Scan Code Bit-wise Error")
ylim([0 1]);ylabel("Cumulative Probability")
grid on
%----------------------------------------------------------------------
figure(2);
[f1,x1] = ecdf(legit_auth_err);
[f2,x2] = ecdf(intruder_feat_err);
hold on;
plot(x1, f1, 'b-', 'LineWidth', 1.5); % 
plot(x2, f2, 'r--', 'LineWidth', 1.5); % 
x1 = xline(18,':','BCH(255,131)','LineWidth', 1.5);
% xline(7,'-.','LineWidth',1)
hold off;
legend("Legit Auth", "Imp-Own")
%
xlabel("Ear Scan Code Bit-wise Error")
ylim([0 1]);ylabel("Cumulative Probability")
grid on
% -----------------------------------------------------------------------
figure(3);
[f1,x1] = ecdf(legit_auth_err);
[f2,x2] = ecdf(intruder_code_err);
hold on;
plot(x1, f1, 'b-', 'LineWidth', 1.5); % 
plot(x2, f2, 'r--', 'LineWidth', 1.5); % 
x1 = xline(18,':','BCH(255,131)','LineWidth', 1.5);
% xline(7,'-.','LineWidth',1)
hold off;
legend("Legit Auth", "Imp-Code")
%
xlabel("Ear Scan Code Bit-wise Error")
ylim([0 1]);ylabel("Cumulative Probability")
grid on