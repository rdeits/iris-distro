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
