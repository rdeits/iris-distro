from __future__ import division

import numpy as np
from scipy.spatial import ConvexHull


def minkowski_sum(a, b):
    """
    Compute the 2D Minkowski sum of the convex shapes defined by vertices in [a] and [b]
    """
    assert a.shape[0] == 2
    assert b.shape[0] == 2
    if a.shape[1] == 1 or b.shape[1] == 1:
        return a + b
    else:
        p = np.zeros((2, a.shape[1] * b.shape[1]))
        idx = 0
        for j in range(a.shape[1]):
            p[:,idx:idx+b.shape[1]] = a[:,j].reshape((2,-1)) + b
            idx += b.shape[1]
    hull = ConvexHull(p.T)
    return p[:,hull.vertices]

def cspace3(obs, bot, theta_steps):
    """
    Compute the 3D (x, y, yaw) configuration space obstacle for a lit of convex 2D obstacles given by [obs] and a convex 2D robot given by vertices in [bot] at a variety of theta values.

    obs should be a 3D array of size (2, vertices_per_obstacle, num_obstacles)

    bot should be a 2d array of size (2, num_bot_vertices)

    theta_steps can either be a scalar, in which case it specifies the number of theta values, evenly spaced between -pi and +pi; or it can be a vector of theta values.
    """
    bot = -np.array(bot)

    if np.isscalar(theta_steps):
        thetas = np.linspace(-np.pi, np.pi, num=theta_steps)
    else:
        thetas = theta_steps

    c_obs = []
    for k in range(obs.shape[2]):
        for j in range(len(thetas)-1):
            th0 = thetas[j]
            th1 = thetas[j+1]

            bot_rot0 = rotmat(th0).dot(bot)
            c_obs0 = minkowski_sum(bot_rot0, obs[:,:,k])

            bot_rot1 = rotmat(th1).dot(bot)
            c_obs1 = minkowski_sum(bot_rot1, obs[:,:,k])

            c_pts = np.vstack((np.hstack((c_obs0, c_obs1)),
                               np.hstack((th0 + np.zeros(c_obs0.shape[1]),
                                          th1 + np.zeros(c_obs1.shape[1])))))
            c_obs.append(c_pts)
    if len(c_obs) == 0:
        return np.zeros((3, bot.shape[1] * 2, 0))
    max_n_vert = max((x.shape[1] for x in c_obs))
    return np.dstack((np.pad(c, pad_width=((0,0), (0,max_n_vert-c.shape[1])), mode='edge') for c in c_obs))


def rotmat(theta):
    c = np.cos(theta)
    s = np.sin(theta)
    return np.array([[c, -s], [s, c]])