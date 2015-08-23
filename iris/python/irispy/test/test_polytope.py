import irispy
import numpy as np
import unittest
import matplotlib.pyplot as plt
import mpl_toolkits.mplot3d as a3

class PolyhedronTest(unittest.TestCase):
    def test_constructor(self):
        p = irispy.Polyhedron()
        A = np.zeros((2,2))

        # print A
        p.setA(A)
        A2 = p.getA()
        A2[0,0] = 1
        self.assertAlmostEqual(p.getA()[0,0], 0.0)

    def test_generators(self):
        p = irispy.Polyhedron()
        A = np.vstack((np.eye(2),
                       -np.eye(2)))
        b = np.array([1.1, 1.2, 1.3, 1.4])
        p.setA(A)
        p.setB(b)
        points = p.generatorPoints()

        expected = [np.array([1.1, 1.2]),
                    np.array([-1.3, 1.2]),
                    np.array([-1.3, -1.4]),
                    np.array([1.1, -1.4])]
        found_expected = [False for i in expected]

        for point in points:
            for i, ex in enumerate(expected):
                if np.all(np.abs(point.T - ex) < 1e-3):
                    found_expected[i] = True
        self.assertTrue(all(found_expected))

    def test_plotting(self):
        fig = plt.figure()
        ax = fig.add_subplot(1,1,1)
        p = irispy.Polyhedron()
        A = np.vstack((np.eye(2),
                       -np.eye(2)))
        b = np.array([1.1, 1.2, 1.3, 1.4])
        p.setA(A)
        p.setB(b)
        p.draw(ax, alpha=0.5)
        ax.relim()
        ax.autoscale_view()
        # plt.show()

    def test_plotting_3d(self):
        fig = plt.figure()
        ax = a3.Axes3D(fig)
        p = irispy.Polyhedron()
        A = np.vstack((np.eye(3),
                       -np.eye(3)))
        b = np.array([1.1, 1.2, 1.3, 1.4, 1.5, 1.6])
        p.setA(A)
        p.setB(b)
        p.draw(ax)
        ax.relim()
        ax.autoscale_view()
        # plt.show()

if __name__ == '__main__':
    unittest.main()


