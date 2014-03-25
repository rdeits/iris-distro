function poly_segmentation_2d(record)
import iris.inflate_region;
import iris.drawing.*;

if nargin < 1
  record = false;
end

lb = [0;0];
ub = [10;10];

obs_offsets = [3, 3, -3, -3;
                     -1.5, 1.5, 1.5, -1.5];
obstacles{1} = bsxfun(@plus, [3;1.5], obs_offsets);
obstacles{2} = bsxfun(@plus, [3;8.5], obs_offsets);


A_bounds = [-1,0;0,-1;1,0;0,1];
b_bounds = [-lb; ub];

start = [3;5];


if record
  w = VideoWriter(['videos/', datestr(now,'yyyy-mm-dd_HH.MM.SS'), '_poly_segmentation_2d']);
  w.FrameRate = 5;
  w.open();
end

  function callback(A,b,C,d,obstacles)
    import iris.drawing.draw_2d;
    h = draw_2d(A,b,C,d,[],lb,ub);
    if record
      w.writeVideo(getframe(h));
      frame = frame + 1;
    end
  end

profile on
[A,b,C,d,history] = inflate_region(obstacles, A_bounds, b_bounds, start, @callback);
profile viewer
draw_2d(A,b,C,d,obstacles,lb,ub);
axis off
plot(start(1), start(2), 'go', 'MarkerSize', 15, 'MarkerFaceColor', 'g')
if record
  w.close();
end

end
