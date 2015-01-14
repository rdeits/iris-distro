classdef TerrainRegion
% A special class to describe a planar polytope of safe terrain. The inequality constraints
% refer to the x, y, and yaw positions of a robot's foot, and the point and normal values
% indicate the plane in x, y, z. 
  properties
    A
    b
    C
    d
    point
    normal
  end

  methods
    function obj = TerrainRegion(A, b, C, d, point, normal)
      obj.A = A;
      obj.b = b;
      obj.C = C;
      obj.d = d;
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

    function ell = getXYEllipsoid(obj)
      C = obj.C(1:2,1:2);
      d = obj.d(1:2);
      ell = iris.Ellipsoid(C, d);
    end

  end
end

