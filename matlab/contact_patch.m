vertices = [0 0 0; % 1
            1 0 0; % 2
            1 1 0; % 3
            0 1 0; % 4
            0 0 1; % 5
            1 0 1; % 6
            1 1 1; % 7
            0 1 1]'; % 8
faces = [1 2 3;
         3 4 1;
         1 5 6;
         6 2 1;
         2 6 3;
         3 6 7;
         3 7 8;
         8 4 3;
         4 8 5;
         5 1 4;
         5 8 7;
         7 6 5]';
normals = zeros(3, size(faces,2));
for j = 1:size(faces, 2)
  normals(:,j) = -cross(vertices(:,faces(2,j)) - vertices(:,faces(1,j)),...
                       vertices(:,faces(3,j)) - vertices(:,faces(2,j)));
  normals(:,j) = normals(:,j) / norm(normals(:,j));
end
       
figure(1)
clf
plot_mesh(vertices, faces, normals)

seed_idx = 12;
seed_pt = mean(vertices(:,faces(:,seed_idx)), 2);
seed_normal = normals(:,seed_idx);
xprime = vertices(:,faces(1,seed_idx)) - seed_pt;
xprime = xprime / norm(xprime);
yprime = cross(seed_normal, xprime);
yprime = yprime / norm(yprime);

prods = sum(bsxfun(@times, seed_normal, normals), 1);
obs_mask = prods >= 0 & prods < 0.5;
obs_idx = find(obs_mask);
obstacles = cell(1,length(obs_idx));
for j = 1:length(obs_idx)
  v = bsxfun(@minus, vertices(:,faces(:,obs_idx(j))'), seed_pt);
  v_dot_xprime = sum(bsxfun(@times, v, xprime), 1);
  v_dot_yprime = sum(bsxfun(@times, v, yprime), 1);
%   d = sum(bsxfun(@times, v, seed_normal), 1);
  obstacles{j} = [v_dot_xprime; v_dot_yprime];
%   obstacles{j} = bsxfun(@plus, seed_pt, ...
%                         v - repmat(d,3,1) .* repmat(seed_normal,1,3));
end

figure(2)
clf
for j = 1:length(obstacles)
  patch(obstacles{j}(1,:), obstacles{j}(2,:), 'k', 'FaceAlpha', 0.5)
end
lb = [-1;-1];
ub = [1;1];
A_bounds = [-diag(ones(2,1)); diag(ones(2,1))];
b_bounds = [-lb; ub];
start = [0;0];
[A, b, C, d, results] = iris.inflate_region(obstacles, A_bounds, b_bounds, start);
iris.drawing.animate_results(results);

A_3d = A * [reshape(xprime, 1, []); reshape(yprime, 1, [])];
b_3d = b + A * [reshape(xprime, 1, []); reshape(yprime, 1, [])] * seed_pt;
A_3d = [A_3d; reshape(seed_normal, 1, []); reshape(-seed_normal, 1, [])];
b_3d = [b_3d; dot(seed_normal, seed_pt) + 1e-2; -dot(seed_normal, seed_pt)];
figure(1)
V = iris.thirdParty.polytopes.lcon2vert(A_3d, b_3d);
iris.drawing.drawPolyFromVertices(V', 'r');