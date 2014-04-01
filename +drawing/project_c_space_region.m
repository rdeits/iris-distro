function project_c_space_region(h, A, b )
% Given a polytope of free C-space Ax <= b, project it down into the plane.
% Draws a green patch where the polytope contains all orientations of the
% bot, and a yellow patch where the polytope contains only some 
% orientations of the bot. 

import iris.thirdParty.polytopes.lcon2vert;
figure(h)
V = lcon2vert(A, b)';

projected_outer_poly = V(1:2,convhull(V(1,:), V(2,:), 'simplify', true));
patch(projected_outer_poly(1,:), projected_outer_poly(2,:), 'y', 'FaceAlpha', 0.5);

top_face = [];
bottom_face = [];

top_face_pts = V(:,abs(V(3,:) - pi) < 1e-4);
if size(top_face_pts, 2) > 2
  try
    k = convhull(top_face_pts(1,:), top_face_pts(2,:), 'simplify', true);
    top_face = top_face_pts(:,k(end:-1:1));
  end
end

bottom_face_pts = V(:,abs(V(3,:) - pi) < 1e-4);
if size(bottom_face_pts, 2) > 2
  try
    k = convhull(bottom_face_pts(1,:), bottom_face_pts(2,:), 'simplify', true);
    bottom_face = bottom_face_pts(:,k(end:-1:1));
  end
end

if ~isempty(top_face) && ~isempty(bottom_face)
  [intersect_face(1,:), intersect_face(2,:)] = polybool('intersection',...
                            top_face(1,:), top_face(2,:),...
                            bottom_face(1,:), bottom_face(2,:));
  if ~isempty(intersect_face)
    patch(intersect_face(1,:), intersect_face(2,:), 'g', 'FaceAlpha', 0.5);
  end
end

end

