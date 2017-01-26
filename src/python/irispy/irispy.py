from __future__ import absolute_import

import numpy as np

from .iris_wrapper import IRISOptions, IRISRegion, IRISProblem

from .iris_wrapper import IRISDebugData, Ellipsoid, Polyhedron
from .iris_wrapper import inflate_region as c_inflate_region
from . import drawing
from . import extensions


Polyhedron.fromBounds = classmethod(extensions.PolyhedronExtension.fromBounds)
Polyhedron.from_bounds = Polyhedron.fromBounds
Polyhedron.getDrawingVertices = \
    extensions.PolyhedronExtension.getDrawingVertices
Polyhedron.default_color = "r"
Polyhedron.draw = drawing.DrawDispatcher.draw
Polyhedron.draw2d = drawing.DrawDispatcher.draw2d
Polyhedron.draw3d = drawing.DrawDispatcher.draw3d

Ellipsoid.getDrawingVertices = \
    extensions.EllipsoidExtension.getDrawingVertices
Ellipsoid.default_color = "r"
Ellipsoid.draw = drawing.DrawDispatcher.draw
Ellipsoid.draw2d = drawing.DrawDispatcher.draw2d
Ellipsoid.draw3d = drawing.DrawDispatcher.draw3d

IRISDebugData.animate = extensions.IRISDebugDataExtension.animate
IRISDebugData.iterRegions = extensions.IRISDebugDataExtension.iterRegions


def inflate_region(obstacles,
                   start_point_or_ellipsoid,
                   bounds=None,
                   require_containment=False,
                   required_containment_points=[],
                   error_on_infeasible_start=False,
                   termination_threshold=2e-2,
                   iter_limit=100,
                   return_debug_data=False):
    if not isinstance(start_point_or_ellipsoid, Ellipsoid):
        # Assume it's a starting point instead

        seed_ellipsoid = Ellipsoid.fromNSphere(start_point_or_ellipsoid)
    else:
        seed_ellipsoid = start_point_or_ellipsoid

    dim = seed_ellipsoid.getDimension()
    problem = IRISProblem(dim)
    problem.setSeedEllipsoid(seed_ellipsoid)

    for obs in obstacles:
        problem.addObstacle(obs)

    if bounds is not None:
        problem.setBounds(bounds)

    options = IRISOptions()
    options.require_containment = require_containment
    options.required_containment_points = required_containment_points
    options.error_on_infeasible_start = error_on_infeasible_start
    options.termination_threshold = termination_threshold
    options.iter_limit = iter_limit

    if return_debug_data:
        debug = IRISDebugData()
        region = c_inflate_region(problem, options, debug)
        return region, debug
    else:
        region = c_inflate_region(problem, options)
        return region
