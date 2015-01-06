classdef Polytope

  properties
    A;
    b;
    Aeq = [];
    beq = [];
    vertices;
    has_vertices = false;
  end

  methods
    function obj = Polytope(A, b, Aeq, beq)
      if nargin < 3
        Aeq = [];
      end
      if nargin < 4
        beq = [];
      end
      obj.A = A;
      obj.b = b;
      obj.Aeq = Aeq;
      obj.beq = beq;
    end

    function vertices = getVertices(obj)
      if ~obj.has_vertices
        if exist('cddmex', 'file')
          H = struct('A', [obj.Aeq; obj.A], 'B', [obj.beq; obj.b], 'lin', (1:size(obj.Aeq, 1))');
          V = cddmex('extreme', H);
          obj.vertices = V.V';
        else
          obj.vertices = iris.thirdParty.polytopes.lcon2vert(obj.A, obj.b, obj.Aeq, obj.beq)';
        end
        obj.has_vertices = true;
      end
      vertices = obj.vertices;
    end
    
    function reduced_poly = reduce(obj)
      % Find a minimal representation of the polytope
      if ~exist('cddmex', 'file')
        error('IRIS:MissingDependency', 'This function requires the cddmex tool. The easiest way to get it is using tbxmanager: http://www.tbxmanager.com/');
      end
      H = struct('A', [obj.Aeq; obj.A], 'B', [obj.beq; obj.b], 'lin', (1:size(obj.Aeq, 1))');
      Hred = cddmex('reduce_h', H);
      assert(isempty(Hred.lin), 'as far as I know, Hred.lin should always be empty. That is, the reduced polytope should not contain equality constraints. -rdeits');
      reduced_poly = iris.Polytope(Hred.A, Hred.B);
    end

    function plotVertices(obj, varargin)
      vertices = obj.getVertices();
      k = convhull(vertices(1,:), vertices(2,:));
      plot(vertices(1,k), vertices(2,k), varargin{:});
    end

    function drawLCMGL(obj, lcmgl)
      lcmgl.glBegin(lcmgl.LCMGL_LINES);
      vertices = obj.getVertices();
      k = convhull(vertices(1,:), vertices(2,:));
      for j = 1:length(k)-1
        lcmgl.glVertex3d(vertices(1,k(j)), vertices(2,k(j)), vertices(3,k(j)));
        lcmgl.glVertex3d(vertices(1,k(j+1)), vertices(2,k(j+1)), vertices(3,k(j+1)));
      end
      lcmgl.glEnd();
    end

  end

  methods(Static)
    function obj = fromVertices(vertices)
      [A, b] = iris.thirdParty.polytopes.vert2lcon(vertices');
      obj = iris.Polytope(A, b);
    end

    function obj = from2DVertices(vertices)
      assert(size(vertices, 1) == 2);
      X = vertices(1,:);
      Y = vertices(2,:);
      k = convhull(x,y, 'simplify', true);
      A = [(y(k(2:end)) - y(k(1:end-1)))', (x(k(1:end-1)) - x(k(2:end)))'];
      b = sum(A' .* [x(k(1:end-1)); y(k(1:end-1))], 1)';
      obj = iris.Polytope(A, b);
    end

    function obj = from2DVerticesAndPlane(vertices, normal, v)
      assert(size(vertices, 1) == 2);
      % normal' * [x;y;z] = v;
      obj = iris.Polytope.from2DVertices(vertices);
      obj.Aeq = reshape(normal, 1, []);
      obj.beq = v;
      obj.A = [obj.A, zeros(size(obj.A, 1), 1)];
    end
  end
end
