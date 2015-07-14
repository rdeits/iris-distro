import irispy
import numpy as np

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
print start, start.getDimension(), start.getC()

region = irispy.run_iris(obstacles, start)

print region.getEllipsoid().getC()
print region.getEllipsoid().getD()