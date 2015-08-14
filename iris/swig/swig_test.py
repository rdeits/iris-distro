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

import irispy_swig_wrapper
p2 = irispy_swig_wrapper.Polyhedron()
p2.setA(np.eye(2))
p2.setB(np.array([3.0, 4.0]))
print p2.contains(np.array([2.5, 5.5]), 0.0)
p2.printGenerators()

p3 = irispy_swig_wrapper.Polyhedron.fromBounds([-1,-1], [2,2])
p3.printGenerators()

problem = irispy_swig_wrapper.IRISProblem(2)
print "made problem"
problem.setBounds(irispy_swig_wrapper.Polyhedron.fromBounds([-1,-1], [2,2]))
print "set bounds"
problem.setSeedPoint(np.array([0.0, 0.0]))
print "set seed"
problem.addObstacle(np.array([[1.5, 2], [1.5, 2]]))
print "added obstacle"
region = irispy_swig_wrapper.inflate_region(problem, irispy_swig_wrapper.IRISOptions())
print region
print region.getPolyhedron().generatorPoints()
print region.getEllipsoid().getC()
print region.getEllipsoid().getD()
