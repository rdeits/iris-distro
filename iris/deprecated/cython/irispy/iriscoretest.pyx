from iriscore cimport copyToMatrix, MatrixXd
from iriscore cimport eigenMatrixToNumpy
import numpy as np
cimport numpy as np
import unittest

class ArrayConversionTest(unittest.TestCase):
    def test_numpy_to_eigen_to_numpy(self):
        cdef MatrixXd numpy_to_eigen
        cdef np.ndarray[double, ndim=2, mode="c"] obstacle
        for dim in range(1,10):
            obstacle = np.random.random(size=(dim, 3*dim))

            numpy_to_eigen = copyToMatrix(&obstacle[0,0], obstacle.shape[0], obstacle.shape[1])

            numpy_to_eigen_to_numpy = eigenMatrixToNumpy(numpy_to_eigen)

            assert((obstacle == numpy_to_eigen_to_numpy).all())

            