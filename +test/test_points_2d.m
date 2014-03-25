function test_points_2d()
import iris.drawing.*
import iris.inflate_region;

m = 10;
n = 10;
grid = random('uniform', 0, 1, m,n) < 0.5;

idx = find(~grid);
[r,c] = ind2sub(size(grid), idx);
obstacles = mat2cell([r'; c'], 2, ones(1,length(r)));

lb = [1;1];
ub = [m;n];
A = [-1,0;0,-1;1,0;0,1];
b = [-lb;ub];
start = [m/2 + 0.25; n/2 + 0.25];

function callback(A,b,C,d,obstacles)
  h = draw_2d(A,b,C,d,obstacles,lb,ub);
end
[A,b,C,d] = inflate_region(obstacles, A, b, start, @callback);

% draw_2d(A,b,C,d,obstacles, [], [-1;-1],[m;n])

end