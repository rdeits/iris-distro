import irispy
import numpy as np
from unittest import TestCase


class IRISTest(TestCase):
    def test_box(self):
        obstacles = [np.array([[0.0, 1.0],
                               [0.0, 0.0]]),
                     np.array([[1.0, 1.0],
                               [0.0, 1.0]]),
                     np.array([[1.0, 0.0],
                               [1.0, 1.0]]),
                     np.array([[0.0, 0.0],
                               [1.0, 0.0]])
                     ]
        start = irispy.Ellipsoid.fromNSphere(np.array([0.1, 0.1]))

        region = irispy.inflate_region(obstacles, start)

        C = region.getEllipsoid().getC()
        self.assertAlmostEqual(C[0,0], 0.5, 3)
        self.assertAlmostEqual(C[0,1], 0.0, 3)

        d = region.getEllipsoid().getD()
        self.assertAlmostEqual(d[0], 0.5, 3)
        self.assertAlmostEqual(d[1], 0.5, 3)

    def test_point_start(self):
        obstacles = [np.array([[0.0, 1.0],
                               [0.0, 0.0]]),
                     np.array([[1.0, 1.0],
                               [0.0, 1.0]]),
                     np.array([[1.0, 0.0],
                               [1.0, 1.0]]),
                     np.array([[0.0, 0.0],
                               [1.0, 0.0]])
                     ]
        start = np.array([0.1, 0.1])

        region = irispy.inflate_region(obstacles, start)

        C = region.getEllipsoid().getC()
        self.assertAlmostEqual(C[0,0], 0.5, 3)
        self.assertAlmostEqual(C[0,1], 0.0, 3)

        d = region.getEllipsoid().getD()
        self.assertAlmostEqual(d[0], 0.5, 3)
        self.assertAlmostEqual(d[1], 0.5, 3)

def test_debug_data():
    import matplotlib.pyplot as plt

    obstacles = [np.array([[0.3, 0.5, 1.0, 1.0],
                           [0.1, 1.0, 1.0, 0.0]])]
    bounds = irispy.Polyhedron()
    bounds.setA(np.vstack((np.eye(2), -np.eye(2))))
    bounds.setB(np.array([2.0, 2, 2, 2]))
    start = np.array([0.1, -0.05])

    # print "running with debug"
    region, debug = irispy.inflate_region(obstacles, start, bounds=bounds, return_debug_data=True)
    # print "done"

    debug.animate(pause=0.5, show=False)


