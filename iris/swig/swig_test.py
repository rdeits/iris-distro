import irispy_swig
import numpy as np

p = irispy_swig.Polyhedron()
p.setA(np.eye(2))
p.setB(np.array([3.0, 4.0]))

print p.contains(np.array([2.5, 5.5]), 0.0)
try:
    print p.contains(5, 0.0)
except Exception as e:
    print e

print p.generatorPoints()
print p.generatorPoints()[0]
for pt in p.generatorPoints():
    print "generator:", pt
