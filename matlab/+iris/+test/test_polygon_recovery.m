function test_polygon_recovery(record)
import iris.inflate_region;

if nargin < 1
  record = false;
end

r = 1;

lb = [-r;-r];
ub = [r;r];

n_obs = 7;
obstacles = {};
th = linspace(0,2*pi,n_obs+1);
% th = [0,pi/4,pi/2,pi,5*pi/4,3*pi/2,2*pi];

% th = cumsum(random('uniform', 0, 3*pi/2, 6, 1));
% th = th * (2*pi / th(end));

for j = 1:length(th)-1
  obstacles{j} = [[r*cos(th(j));r*sin(th(j))],[r*cos(th(j+1));r*sin(th(j+1))]];
end

A_bounds = [-1,0;0,-1;1,0;0,1];
b_bounds = [-lb; ub];

start = 0.5*[random('uniform',lb(1),ub(1));
             random('uniform',lb(2),ub(2))];
% start = [0;0];
% start = [0;0.98];


if record
  w = VideoWriter(['videos/', datestr(now,'yyyy-mm-dd_HH.MM.SS'), '_poly_segmentation_2d']);
  w.FrameRate = 5;
  w.open();
end

  function callback(A,b,C,d,obstacles)
    import iris.drawing.draw_2d;
    h = draw_2d(A,b,C,d,obstacles,lb,ub);
%     axis equal
    drawnow();
%     pause
    if record
      w.writeVideo(getframe(h));
      frame = frame + 1;
    end
  end

profile on
[A,b,C,d] = inflate_region(obstacles, A_bounds, b_bounds, start, @callback);
profile viewer
if record
  w.close();
end

end
