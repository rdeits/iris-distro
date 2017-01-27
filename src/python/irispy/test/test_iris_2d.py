import irispy
import numpy as np

def test_random_obstacles_2d(show=False):
    bounds = irispy.Polyhedron.from_bounds([0, 0], [1, 1])
    obstacles = []
    for i in range(10):
        center = np.random.random((2,))
        scale = np.random.random() * 0.3
        pts = np.random.random((2,4))
        pts = pts - np.mean(pts, axis=1)[:,np.newaxis]
        pts = scale * pts + center[:,np.newaxis]
        obstacles.append(pts)
        start = np.array([0.5, 0.5])

    region, debug = irispy.inflate_region(obstacles, start, bounds=bounds, return_debug_data=True)

    debug.animate(pause=0.5, show=show)

if __name__ == '__main__':
    test_random_obstacles_2d(True)