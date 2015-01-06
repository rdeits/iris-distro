classdef TerrainRegion
% A special class to describe a planar polytope of safe terrain. The inequality constraints
% refer to the x, y, and yaw positions of a robot's foot, and the point and normal values
% indicate the plane in x, y, z. 
  properties
    A
    b
    point
    normal
  end

  methods
    function obj = TerrainRegion(A, b, point, normal)
      obj.A = A;
      obj.b = b;
      obj.point = point;
      obj.normal = normal;
    end

    function poly = getXYZPolytope(obj)
      A = [obj.A(:,1:2), zeros(size(obj.A, 1), 1)];
      b = obj.b;
      n = reshape(obj.normal, 1, []);
      p = reshape(obj.point, [], 1);
      poly = iris.Polytope(A, b, n, n * p);
    end
  end
end

