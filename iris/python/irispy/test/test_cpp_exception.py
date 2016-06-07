import irispy
import numpy as np
from unittest import TestCase


class CPPExcpetionTest(TestCase):
    def test_dimension_error(self):
        obstacles = [np.array([[2., 0], [2, 2], [3, 2], [3, 0]]).T]
        bounds = irispy.Polyhedron.fromBounds([-1, -1], [3, 3])
        seed_point = np.array([1.0, 2.0])

        # this should pass
        region = irispy.inflate_region(obstacles, seed_point, bounds)


        # Now the obstacle is the wrong shape, so we should get a runtime error (but not a crash)
        obstacles = [np.array([[2., 0], [2, 2], [3, 2], [3, 0]])]
        try:
            region = irispy.inflate_region(obstacles, seed_point, bounds)
            self.assertTrue(False) # This should not have succeeded
        except RuntimeError as e:
            self.assertTrue(str(e) == "The matrix of obstacle vertices must have the same number of row as the dimension of the problem")


