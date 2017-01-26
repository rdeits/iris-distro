import numpy as np


def getDrawingVertices(self):
    if self.getDimension() == 2:
        theta = np.linspace(0, 2 * np.pi, 100)
        y = np.vstack((np.sin(theta), np.cos(theta)))
        return (self.getC().dot(y) + self.getD().reshape((-1, 1))).T
    elif self.getDimension() == 3:
        theta = np.linspace(0, 2 * np.pi, 20)
        y = np.vstack((np.sin(theta), np.cos(theta), np.zeros_like(theta)))
        for phi in np.linspace(0, np.pi, 10):
            R = np.array([[1.0, 0.0, 0.0],
                          [0.0, np.cos(phi), -np.sin(phi)],
                          [0.0, np.sin(phi), np.cos(phi)]])
            y = np.hstack((y, R.dot(y)))
        x = self.getC().dot(y) + self.getD().reshape((-1, 1))
        return x.T
    else:
        raise NotImplementedError("Ellipsoid vertices not implemented for dimension < 2 or > 3")
