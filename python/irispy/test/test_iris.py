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

def test_debug_data():
    import matplotlib.pyplot as plt

    obstacles = [np.array([[0.3, 0.5, 1.0, 1.0],
                           [0.1, 1.0, 1.0, 0.0]])]
    bounds = irispy.Polytope()
    bounds.setA(np.vstack((np.eye(2), -np.eye(2))))
    bounds.setB(np.array([2.0, 2, 2, 2]))
    start = [0.1, -0.05]

    print "running with debug"
    region, debug = irispy.inflate_region(obstacles, start, bounds=bounds, return_debug_data=True)
    print "done"

    debug.animate()
    plt.show()

    # fig = plt.figure()
    # ax = fig.add_subplot(1,1,1)
    # plt.ion()

    # for poly, ellipsoid in debug.iterRegions():
    #     print poly.generatorPoints()
    #     poly.draw(ax)
    #     ellipsoid.draw(ax)
    #     # ax.relim()
    #     ax.set_xlim([-2.5, 2.5])
    #     ax.set_ylim([-2.5, 2.5])
    #     # ax.autoscale_view()
    #     plt.draw()
    #     # plt.show()
    #     plt.waitforbuttonpress()
    #     ax.cla()
    #     # raw_input()
    # plt.ioff()
    # plt.show()

if __name__ == '__main__':
    test_debug_data()
