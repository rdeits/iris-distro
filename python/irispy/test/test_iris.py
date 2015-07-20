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

    def test_debug_data(self):
        import matplotlib.pyplot as plt

        obstacles = [np.array([[0.3, 0.5, 1.0, 1.0],
                               [0.1, 1.0, 1.0, 0.0]])]
        bounds = irispy.Polytope()
        bounds.setA(np.vstack((np.eye(2), -np.eye(2))))
        bounds.setB(np.array([2.0, 2, 2, 2]))
        start = [0.1, -0.05]

        # print "running with debug"
        region, debug = irispy.inflate_region(obstacles, start, bounds=bounds, return_debug_data=True)
        # print "done"

        debug.animate(pause=0.5, show=True)

    def test_random_obstacles_2d(self):
        bounds = irispy.Polytope.from_bounds([0, 0], [1, 1])
        obstacles = []
        for i in range(5):
            center = np.random.random((2,))
            scale = np.random.random() * 0.3
            pts = np.random.random((2,4))
            pts = pts - np.mean(pts, axis=1)[:,np.newaxis]
            pts = scale * pts + center[:,np.newaxis]
            obstacles.append(pts)
            start = [0.0, 0.0]

        region, debug = irispy.inflate_region(obstacles, start, bounds=bounds, return_debug_data=True)

        debug.animate(pause=0.5, show=True)




