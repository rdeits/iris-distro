from __future__ import division

import numpy as np
import mosek.fusion
from irispy.hyperplanes import compute_obstacle_planes
from irispy.mosek_ellipsoid.lownerjohn_ellipsoid import lownerjohn_inner

def inflate_region(obstacle_pts, A_bounds, b_bounds, start, require_containment=False, iter_limit=np.inf):
    A_bounds = np.array(A_bounds)
    b_bounds = np.array(b_bounds)
    d = np.array(start)
    dim = A_bounds.shape[1]
    C = 0.01 * np.eye(dim)
    best_vol = 1e-100
    results = {'p_history': [], 'e_history': []}
    iters = 1

    while True:
        A, b, infeas_start = compute_obstacle_planes(obstacle_pts, C, d)
        # print "number of hyperplanes:", len(b)
        A = np.vstack((A, A_bounds))
        b = np.hstack((b, b_bounds))

        if require_containment:
            if np.all(A.dot(start) <= b) or iters == 1 or infeas_start:
                results['p_history'].append({'A': A, 'b': b})
            else:
                A = results['p_history'][-1]['A']
                b = results['p_history'][-1]['b']
                print "Breaking early because start point is no longer contained in polytope"
                break
        else:
            results['p_history'].append({'A': A, 'b': b})

        iters += 1

        if iters > iter_limit:
            print "iter limit reached"
            break

        try:
            C, d = lownerjohn_inner(A, b)
        except mosek.fusion.SolutionError:
            print "Breaking early beause ellipsoid maximization failed"
            break

        C = np.array(C)
        d = np.array(d)

        vol = np.linalg.det(C)
        results['e_history'].append({'C': C, 'd': d})

        if abs(vol - best_vol) / best_vol < 2e-2:
            break
        best_vol = vol
    return A, b, C, d, results




