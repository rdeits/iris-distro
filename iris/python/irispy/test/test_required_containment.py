import irispy
import numpy as np
import unittest

class ContainmentTest(unittest.TestCase):
    def test_required_containment(self):
        obstacles = [np.array([[0., 1],
                               [0, 0]]),
                     np.array([[1., 1],
                               [0, 1]]),
                     np.array([[1., 0],
                               [1, 1]]),
                     np.array([[0., 0],
                               [1, 0]])]
        required_containment_pts = [np.array([1.5, 1.5])]
        start = np.array([0.1, 0.1])

        region = irispy.inflate_region(obstacles, start,
                                       require_containment=True,
                                       required_containment_points=required_containment_pts)
        self.assertTrue(region.polyhedron.getNumberOfConstraints() == 0, "polyhedron should be empty")

if __name__ == '__main__':
    unittest.main()