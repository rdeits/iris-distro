from __future__ import division

import numpy as np
from scipy import ndimage
from collections import OrderedDict

import drc
from irispy.cspace import cspace3
from irispy.iris import inflate_region

DEFAULT_FOOT_CONTACTS = np.array([[-0.1170, -0.1170, 0.1170, 0.1170],
                                  [0.0562, -0.0562, 0.0562, -0.0562]])
DEFAULT_BOUNDING_BOX_WIDTH = 1
DEFAULT_CONTACT_SLICES = {(0.05, 0.3): np.array([[-0.1170, -0.1170, 0.1170, 0.1170],
                                          [0.0562, -0.0562, 0.0562, -0.0562]]),
                          (0.3, 1.0): np.array([[-0.1170, -0.1170, 0.30, 0.30],
                                          [.25, -.25, .25, -.25]])}

def classify_terrain(heights, px2world):
    # heights[np.isnan(heights)] = 0 # TODO: make sure these are filled properly
    sx = ndimage.sobel(heights, axis=0, mode='constant')
    sy = ndimage.sobel(heights, axis=1, mode='constant')
    sob = np.hypot(sx, sy)
    # sob[np.isnan(sob)] = np.inf
    sob[np.isnan(sob)] = 0
    edges = sob > 0.5 # TODO: maybe not just a magic constant?
    edges[np.isnan(heights)] = False
    feas = np.logical_not(edges)

    return feas


def terrain_edge_obs(feas, px2world_2x3):
    C, R = np.meshgrid(range(feas.shape[1]), range(feas.shape[0]))
    mask = np.logical_not(feas)
    cr = np.vstack((C[mask], R[mask]))
    obs_flat = px2world_2x3.dot(np.vstack((cr, np.ones(cr.shape[1]))))
    obs = obs_flat.reshape((2,1,-1))
    return obs

def terrain_body_obs(heights, px2world_2x3, pose, ht_range):
    # TODO: use a plane fit, rather than just a horizontal plane
    C, R = np.meshgrid(range(heights.shape[1]), range(heights.shape[0]))
    delta = heights - pose[2]
    print delta
    obs_mask = np.logical_and(ht_range[0] <= delta, delta <= ht_range[1])
    cr = np.vstack((C[obs_mask], R[obs_mask]))
    obs_flat = px2world_2x3.dot(np.vstack((cr, np.ones(cr.shape[1]))))
    obs_flat = np.vstack((obs_flat, heights[obs_mask]))
    obs = obs_flat.reshape((3,1,-1))
    return obs


class TerrainSegmentation:
    def __init__(self, bot_pts=DEFAULT_FOOT_CONTACTS,
                 bounding_box_width=DEFAULT_BOUNDING_BOX_WIDTH,
                 contact_slices=DEFAULT_CONTACT_SLICES):
        self.bot_pts = bot_pts
        self.bounding_box_width = bounding_box_width
        self.contact_slices = contact_slices
        self.heights = None
        self.px2world = None
        self.feas = None
        self.edge_pts_xy = None
        self.obs_pts_xyz = None
        self.last_obs_mask = None

    def setHeights(self, heights, px2world=None):
        if px2world is not None:
            self.px2world = px2world
        C, R = np.meshgrid(range(heights.shape[1]), range(heights.shape[0]))
        self.heights = self.px2world[2,:].dot(np.vstack((C.flatten(), R.flatten(), heights.flatten(), np.ones((1,C.flatten().shape[0]))))).reshape(heights.shape)
        self.feas = classify_terrain(heights, self.px2world)
        self.edge_pts_xy = terrain_edge_obs(self.feas, self.px2world_2x3)

    def findSafeRegion(self, pose, **kwargs):
        start = pose[[0,1,5]] # x y yaw
        A_bounds, b_bounds = self.getBoundingPolytope(start)
        c_obs = self.getCObs(start, self.edge_pts_xy, A_bounds, b_bounds)

        for hts, bot in self.contact_slices.iteritems():
            print "adding body obstacles in height range:", hts
            body_obs_xyz = terrain_body_obs(self.heights, self.px2world_2x3, pose, hts)
            print body_obs_xyz.size
            if body_obs_xyz.size > 0:
                c_obs = np.dstack((c_obs, self.getCObs(start, body_obs_xyz[:2,:], A_bounds, b_bounds, bot=bot)))

        A, b, C, d, results = inflate_region(c_obs, A_bounds, b_bounds, start, **kwargs)
        return SafeTerrainRegion(A, b, C, d, pose)

    def getBoundingPolytope(self, start):
        start = np.array(start).reshape((3,))
        print start
        print self.bounding_box_width
        lb = np.hstack((start[:2] - self.bounding_box_width / 2, start[2] - np.pi))
        ub = np.hstack((start[:2] + self.bounding_box_width / 2, start[2] + np.pi))
        A_bounds = np.vstack((-np.eye(3), np.eye(3)))
        b_bounds = np.hstack((-lb, ub))
        return A_bounds, b_bounds

    def getCObs(self, start, obs_pts, A_bounds, b_bounds, bot=None):
        start = np.array(start).reshape((3,))

        if bot is None:
            bot = self.bot_pts
        Ax = A_bounds.dot(np.vstack((obs_pts.reshape((2,-1)),
                                     start[2] + np.zeros(obs_pts.shape[1]*obs_pts.shape[2]))))
        obs_pt_mask = np.all(Ax - b_bounds.reshape((-1,1)) - np.max(np.abs(bot)) < 0,
                             axis=0).reshape(obs_pts.shape[1:])
        obs_mask = np.any(obs_pt_mask, axis=0)
        self.last_obs_mask = obs_mask
        c_obs = cspace3(obs_pts[:,:,obs_mask], bot, 4)
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

class SafeTerrainRegion:
    __slots__ = ['A', 'b', 'C', 'd']
    def __init__(self, A, b, C, d, pose):
        self.A = A
        self.b = b
        self.C = C
        self.d = d
        self.pose = pose

    def to_iris_region_t(self):
        msg = drc.iris_region_t()
        msg.lin_con = self.to_lin_con_t()
        msg.point = self.pose[:3]
        print "Warning: normal not set"
        msg.normal = [0,0,1] # TODO: set normal from pose
        return msg

    def to_lin_con_t(self):
        msg = drc.lin_con_t()
        msg.m = self.A.shape[0]
        msg.n = self.A.shape[1]
        msg.m_times_n = msg.m * msg.n
        msg.A = self.A.flatten(order='F') # column-major
        msg.b = self.b
        print self.A
        print self.b
        return msg
