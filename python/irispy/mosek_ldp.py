from __future__ import division
import mosek
import sys
import numpy as np

def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()

env = mosek.Env()

def mosek_ldp(ys):
    """
    Use mosek to compute the point in the convex hull of the points in [ys] which is closest to the origin.

    @input ys: an array of size [dimension x number of points]

    @returns ystar: a vector of size [dimension]
    """
    dim = ys.shape[0]
    pts_per_obstacle = ys.shape[1]
    # env.set_Stream(mosek.streamtype.log, streamprinter)
    # task.set_Stream(mosek.streamtype.log, streamprinter)

    bkc = [mosek.boundkey.fx] * (dim+1)
    blc = [0] * dim + [1]
    buc = [0] * dim + [1]

    bkx = [mosek.boundkey.fr] * dim + [mosek.boundkey.lo] * (pts_per_obstacle + 1)
    blx = [-np.inf] * dim + [0] * (pts_per_obstacle + 1)
    bux = [np.inf] * dim + [np.inf] * (pts_per_obstacle + 1)

    c = [0] * (dim + pts_per_obstacle) + [1]
    asub = ([[x] for x in range(dim)]
            + [range(dim + 1) for x in range(pts_per_obstacle)])
    aval = ([[-1] for x in range(dim)]
            + [list(ys[:,j]) + [1] for j in range(pts_per_obstacle)])
    numvar = len(bkx)
    numcon = len(bkc)
    task = env.Task(numvar, numcon)
    task.appendcons(numcon)
    task.appendvars(numvar)

    for j in range(numvar):
        task.putcj(j, c[j])
        task.putbound(mosek.accmode.var,j,bkx[j], blx[j], bux[j])

    for j in range(len(aval)):
        task.putacol(j, asub[j], aval[j])

    for i in range(numcon):
        task.putbound(mosek.accmode.con,i,bkc[i],blc[i],buc[i])

    task.appendcone(mosek.conetype.quad, 0.0, [numvar-1] + range(dim))
    task.putobjsense(mosek.objsense.minimize)
    task.optimize()
    task.solutionsummary(mosek.streamtype.msg)
    xx = np.zeros(numvar, float)
    task.getxx(mosek.soltype.itr, xx)
    return xx[:dim]
