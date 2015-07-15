import irispy
import numpy as np

p = irispy.Polytope()
A = np.zeros((2,2))

print A
p.setA(A)
A2 = p.getA()
A2[0,0] = 1
print A2
print p.getA()

e = irispy.Ellipsoid()
C = np.eye(2)

e.setC(C)
print e.getC()

e2 = irispy.Ellipsoid(3)
print e2.getC()

e3 = irispy.Ellipsoid.fromNSphere(np.array([0.5, 0.5]), radius=0.5)
print e3.getC()
