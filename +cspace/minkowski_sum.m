function p = minkowski_sum(a, b)

p = zeros(2, size(a,2) * size(b,2));
idx = 1;
for j = 1:size(a,2)
  for k = 1:size(b,2)
    p(:,idx) = a(:,j) + b(:,k);
    idx = idx + 1;
  end
end

k = convhull(p(1,:), p(2,:), 'simplify', true);
p = p(:,k);
