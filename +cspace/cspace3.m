function [c] = cspace3(obs, bot, n_theta)
import iris.cspace.minkowski_sum;

bot = -bot;

th = linspace(-pi, pi, n_theta);
c = {};


for j = 1:(length(th)-1)
  rbot0 = rotmat(th(j)) * bot;
  c_obs0 = minkowski_sum(rbot0, obs);
  
  rbot1 = rotmat(th(j+1)) * bot;
  c_obs1 = minkowski_sum(rbot1, obs);
  c_pts = [c_obs0, c_obs1;
          th(j)*ones(1,size(c_obs0,2)), th(j+1)*ones(1,size(c_obs1,2))];
  c_pts = unique(c_pts', 'rows')';
  c{j} = c_pts;
end
  