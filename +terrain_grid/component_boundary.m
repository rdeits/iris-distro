function boundary = component_boundary(grid, ndx)

if length(ndx) == 2
  ndx = sub2ind(size(grid), ndx(1), ndx(2));
end

filled = imfill(~grid, ndx, 8);
component = ~(xor(filled,grid));
boundary = imdilate(component, strel('square', 3)) - component;
% figure()
% subplot(311)
% imshow(grid)
% subplot(312)
% imshow(component)
% subplot(313)
% imshow(boundary);