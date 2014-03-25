function nhat = transformed_normal(y, C)
dim = length(y);

if dim == 3
  [v1, v2] = iris.util.orthos(y);
  u1 = C * v1;
  u2 = C * v2;
  nhat = cross(u1, u2);
  nhat = nhat / norm(nhat);
elseif dim == 2
  nhat = [0,1;-1,0]*C*[0,-1;1,0]*y;
else
  error('Problem must be in 2 or 3 dimensions');
end
nhat = nhat / norm(nhat);