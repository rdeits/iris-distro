import drawing
import itertools
import numpy as np
import matplotlib.pyplot as plt
import mpl_toolkits.mplot3d as a3
import matplotlib.animation as animation

class PolyhedronExtension:
    @classmethod
    def fromBounds(cls, lb, ub):
        """
        Return a new Polyhedron representing an n-dimensional box spanning from [lb] to [ub]
        """
        lb = np.asarray(lb, dtype=np.float64)
        ub = np.asarray(ub, dtype=np.float64)
        p = cls()
        p.setA(np.vstack((np.eye(lb.size), -np.eye(lb.size))))
        p.setB(np.hstack((ub, -lb)))
        return p

    # For backward compatibility
    from_bounds = fromBounds

    def getDrawingVertices(self):
        return np.hstack(self.generatorPoints()).T


class EllipsoidExtension:
    def getDrawingVertices(self):
        if self.getDimension() == 2:
            theta = np.linspace(0, 2 * np.pi, 100)
            y = np.vstack((np.sin(theta), np.cos(theta)))
            return (self.getC().dot(y) + self.getD()).T
        elif self.getDimension() == 3:
            theta = np.linspace(0, 2 * np.pi, 20)
            y = np.vstack((np.sin(theta), np.cos(theta), np.zeros_like(theta)))
            for phi in np.linspace(0, np.pi, 10):
                R = np.array([[1.0, 0.0, 0.0],
                              [0.0, np.cos(phi), -np.sin(phi)],
                              [0.0, np.sin(phi), np.cos(phi)]])
                y = np.hstack((y, R.dot(y)))
            x = self.getC().dot(y) + self.getD()
            return x.T
        else:
            raise NotImplementedError("Ellipsoid vertices not implemented for dimension < 2 or > 3")


class IRISDebugDataExtension:
    def iterRegions(self):
        return itertools.izip(self.polyhedron_history, self.ellipsoid_history)

    def animate(self, fig=None, pause=0.5, show=True, repeat_delay=2.0):
        dim = self.bounds.getDimension()
        if dim < 2 or dim > 3:
            raise NotImplementedError("animation is not implemented for dimension < 2 or > 3")
        if fig is None:
            fig = plt.figure()
            if dim == 3:
                ax = a3.Axes3D(fig)
            else:
                ax = plt.gca()

        bounding_pts = np.hstack(self.boundingPoints()).T
        if bounding_pts.size > 0:
            lb = bounding_pts.min(axis=0)
            ub = bounding_pts.max(axis=0)
            assert(lb.size == dim)
            assert(ub.size == dim)
            width = ub - lb
            ax.set_xlim(lb[0] - 0.1 * width[0], ub[0] + 0.1 * width[0])
            ax.set_ylim(lb[1] - 0.1 * width[1], ub[1] + 0.1 * width[1])
            if dim == 3:
                ax.set_zlim(lb[2] - 0.1 * width[2], ub[2] + 0.1 * width[2])

        artist_sets = []
        for poly, ellipsoid in self.iterRegions():
            artists = []
            d = self.ellipsoid_history[0].getD()
            if dim == 3:
                artists.extend(ax.plot([d[0]], [d[1]], 'go', zs=[d[2]], markersize=10))
            else:
                artists.extend(ax.plot([d[0]], [d[1]], 'go', markersize=10))
            artists.extend(poly.draw(ax))
            artists.extend(ellipsoid.draw(ax))
            for obs in self.getObstacles():
                artists.extend(drawing.draw_convhull(obs.T, ax, edgecolor='k', facecolor='k', alpha=0.5))
            artist_sets.append(tuple(artists))

        ani = animation.ArtistAnimation(fig, artist_sets, interval=pause*1000, repeat_delay=repeat_delay*1000)
        if show:
            plt.show()
