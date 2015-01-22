classdef Heightmap
  % A simple container for height map data stored as a grid of heights with associated normal vectors. 
  properties(SetAccess=private, GetAccess=public)
    X;
    Y;
    Z;
    normals;
    resolution;
  end

  methods
    function obj = Heightmap(X, Y, Z, normals)
      if length(X) == numel(X) && length(Y) == numel(Y) 
        [X, Y] = meshgrid(X, Y);
      end
      obj.X = X;
      obj.Y = Y;
      obj.Z = Z;
      obj.normals = normals;
      assert(all(all(diff(X, 1, 1) == 0)));
      assert(all(all(abs(diff(X, 1, 2) - (X(1,2) - X(1,1))) <= 1e-6)));
      assert(all(all(diff(Y, 1, 2) == 0)));
      assert(all(all(abs(diff(Y, 1, 1) - (Y(2,1) - Y(1,1))) <= 1e-6)));
      obj.resolution = [X(1,2) - X(1,1); Y(2,1) - Y(1,1)];
    end

    function slope_angles = getSlopeAngles(obj)
      slope_angles = atan2(sqrt(sum(obj.normals(1:2,:).^2,1)), obj.normals(3,:));
      slope_angles = reshape(slope_angles, size(obj.X));
    end
  end
end


