import irispy
import numpy as np
from unittest import TestCase

class PolytopeTest(TestCase):
    def test_constructor(self):
        p = irispy.Polytope()
        A = np.zeros((2,2))

        print A
        p.setA(A)
        A2 = p.getA()
        A2[0,0] = 1
        self.assertAlmostEqual(p.getA()[0,0], 0.0)

    def test_generators(self):
        p = irispy.Polytope()
        A = np.vstack((np.eye(2),
                       -np.eye(2)))
        b = np.array([1.1, 1.2, 1.3, 1.4])
        p.setA(A)
        p.setB(b)
        points = p.generatorPoints()
        print points

        expected = [np.array([1.1, 1.2]),
                    np.array([-1.3, 1.2]),
                    np.array([-1.3, -1.4]),
                    np.array([1.1, -1.4])]
        found_expected = [False for i in expected]

        for point in points:
            for i, ex in enumerate(expected):
                if np.all(np.abs(point - ex) < 1e-3):
                    found_expected[i] = True
                    print "found: ", ex
        self.assertTrue(all(found_expected))

