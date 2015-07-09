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
