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
        start = [0.1, 0.1]

        region = irispy.inflate_region(obstacles, start)

        C = region.getEllipsoid().getC()
        self.assertAlmostEqual(C[0,0], 0.5, 3)
        self.assertAlmostEqual(C[0,1], 0.0, 3)

        d = region.getEllipsoid().getD()
        self.assertAlmostEqual(d[0], 0.5, 3)
        self.assertAlmostEqual(d[1], 0.5, 3)
