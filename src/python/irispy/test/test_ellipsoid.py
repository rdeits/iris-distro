import irispy
import numpy as np
from unittest import TestCase


class EllipsoidTest(TestCase):
    def test_volume(self):
        e = irispy.Ellipsoid.fromNSphere(np.array([0., 0.]), 1.0)
        self.assertAlmostEqual(e.getVolume(), np.pi)
        self.assertAlmostEqual(e.getC()[0,0], 1)
        self.assertAlmostEqual(e.getC()[0,1], 0)

        e = irispy.Ellipsoid.fromNSphere(np.array([5.0, 0.1,-1000]), 0.5)
        self.assertAlmostEqual(e.getVolume(), 4.0 / 3.0 * np.pi * 0.5 ** 3)
        self.assertAlmostEqual(e.getC()[1,1], 0.5)

    def test_inner_ellipsoid(self):
        # polyhedron from [-1.3, -1.4] to [1.1, 1.2]
        # center is at [-0.1, -0.1]
        A = np.vstack((np.eye(2),
                       -np.eye(2)))
        b = np.array([1.1, 1.2, 1.3, 1.4])
        p = irispy.Polyhedron(A, b)
        e = irispy.inner_ellipsoid(p)
        self.assertTrue(np.allclose(e.getD(), [-0.1, -0.1]))
        self.assertTrue(np.allclose(e.getC(), np.array([[1.2, 0], [0, 1.3]])))
