function plot_timing_results(all_results)

n_trials = 5;
n_obs = reshape([all_results.n_obs], n_trials, []);
iters = reshape([all_results.iters], n_trials, []);
total_time = reshape([all_results.total_time], n_trials, []);
e_time = reshape([all_results.e_time], n_trials, []);
p_time = reshape([all_results.p_time], n_trials, []);
figure(6)
clf
subplot 211
cla
hold on
errorbar(mean(n_obs), mean(total_time), std(total_time), 'k.-')
errorbar(mean(n_obs), mean(e_time), std(e_time), 'r.-')
errorbar(mean(n_obs), mean(p_time), std(p_time), 'g.-')
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
loglog([1, mean(n_obs(:,end))], [mean(total_time(:,end))/mean(n_obs(:,end)), mean(total_time(:,end))], 'k--')
xlim([min([all_results.n_obs])-1, max([all_results.n_obs])*1.5]);
xlabel('Number of obstacles')
ylabel('CPU Time (s)')
subplot 212
errorbar(mean(n_obs), mean(iters), std(iters), 'ko')
set(gca, 'XScale', 'log');
ylim([0, max(mean(iters) + std(iters)) + 1])
xlim([min([all_results.n_obs])-1, max([all_results.n_obs])*1.5]);
xlabel('Number of obstacles')
ylabel('Number of major iterations')
% h = bar([all_results.n_obs], [all_results.iters]);
% set(h, 'BarWidth', 0.8);