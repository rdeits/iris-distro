function [c] = cspace3(obs, bot, theta_steps)
import iris.cspace.minkowski_sum;
if ~iscell(obs)
  obs = {obs};
end
bot = -bot;

if isscalar(theta_steps)
  th = linspace(-pi, pi, theta_steps);
else
  th = theta_steps;
end

c = cell(1,length(obs) * (length(th)-1));

idx = 1;
for k = 1:length(obs)
  for j = 1:(length(th)-1)
    rbot0 = iris.util.rotmat(th(j)) * bot;
    c_obs0 = minkowski_sum(rbot0, obs{k});

    rbot1 = iris.util.rotmat(th(j+1)) * bot;
    c_obs1 = minkowski_sum(rbot1, obs{k});
    c_pts = [c_obs0, c_obs1;
            th(j)*ones(1,size(c_obs0,2)), th(j+1)*ones(1,size(c_obs1,2))];
    c{idx} = c_pts;
    idx = idx + 1;
  end
end
