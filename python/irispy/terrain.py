from __future__ import division

import numpy as np
from scipy import ndimage
from irispy.cspace import cspace3
from irispy.iris import inflate_region

DEFAULT_FOOT_CONTACTS = np.array([[-0.1170, -0.1170, 0.1170, 0.1170],
                                  [0.0562, -0.0562, 0.0562, -0.0562]])
DEFAULT_BOUNDING_BOX_WIDTH = 1

def classify_terrain(heights, px2world):
    sx = ndimage.sobel(heights, axis=0, mode='constant')
    sy = ndimage.sobel(heights, axis=1, mode='constant')
    sob = np.hypot(sx, sy)
    sob[np.isnan(sob)] = np.inf
    edges = sob > 0.5 # TODO: maybe not just a magic constant?
    edges[np.isnan(heights)] = True
    feas = np.logical_not(edges)

    return feas


def terrain_obstacles(feas, px2world_2x3):
    C, R = np.meshgrid(range(feas.shape[1]), range(feas.shape[0]))
    cr = np.vstack((C[np.logical_not(feas)], R[np.logical_not(feas)]))
    obs_flat = px2world_2x3.dot(np.vstack((cr, np.ones(cr.shape[1]))))
    obs = obs_flat.reshape((2,1,-1))
    return obs

class TerrainSegmentation:
    def __init__(self, bot_pts=DEFAULT_FOOT_CONTACTS,
                 bounding_box_width=DEFAULT_BOUNDING_BOX_WIDTH):
        self.bot_pts = bot_pts
        self.bounding_box_width = bounding_box_width
        self.heights = None
        self.px2world = None
        self.feas = None
        self.obs_pts_xy = None
        self.last_obs_mask = None

    def setHeights(self, heights, px2world=None):
        if px2world is not None:
            self.px2world = px2world
        self.heights = heights
        self.feas = classify_terrain(heights, self.px2world)
        self.obs_pts_xy = terrain_obstacles(self.feas, self.px2world_2x3)

    def findSafeRegion(self, start, **kwargs):
        A_bounds, b_bounds = self.getBoundingPolytope(start)
        c_obs = self.getCObs(start, A_bounds, b_bounds)
        A, b, C, d, results = inflate_region(c_obs, A_bounds, b_bounds, start, **kwargs)
        return A, b, C, d, results

    def getBoundingPolytope(self, start):
        start = np.array(start).reshape((3,))
        print start
        print self.bounding_box_width
        lb = np.hstack((start[:2] - self.bounding_box_width / 2, start[2] - np.pi))
        ub = np.hstack((start[:2] + self.bounding_box_width / 2, start[2] + np.pi))
        A_bounds = np.vstack((-np.eye(3), np.eye(3)))
        b_bounds = np.hstack((-lb, ub))
        return A_bounds, b_bounds

    def getCObs(self, start, A_bounds, b_bounds):
        start = np.array(start).reshape((3,))
        obs = self.obs_pts_xy
        bot = self.bot_pts
        Ax = A_bounds.dot(np.vstack((obs.reshape((2,-1)),
                                     start[2] + np.zeros(obs.shape[1]*obs.shape[2]))))
        obs_pt_mask = np.all(Ax - b_bounds.reshape((-1,1)) - np.max(np.abs(bot)) < 0,
                             axis=0).reshape(obs.shape[1:])
        obs_mask = np.any(obs_pt_mask, axis=0)
        self.last_obs_mask = obs_mask
        c_obs = cspace3(obs[:,:,obs_mask], bot, 4)
        return c_obs


    @property
    def world2px(self):
        return np.linalg.inv(self.px2world)

    @property
    def world2px_2x3(self):
        return self.world2px[:2,[0,1,3]]

    @property
    def px2world_2x3(self):
        return self.px2world[:2,[0,1,3]]

