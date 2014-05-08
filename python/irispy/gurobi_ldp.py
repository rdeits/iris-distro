import gurobipy
import numpy as np

grb_model = gurobipy.Model("ldp")
grb_model.setParam('OutputFlag', False)


def gurobi_ldp(ys):
    """
    Use gurobi to compute the point in the convex hull of the points in [ys] which is closest to the origin.

    @input ys: an array of size [dimension x number of points]

    @returns ystar: a vector of size [dimension]
    """
    grb_model.reset()
    for v in grb_model.getVars():
        grb_model.remove(v)
    for c in grb_model.getConstrs():
        grb_model.remove(c)
    dim = ys.shape[0]
    pts_per_obstacle = ys.shape[1]
    ws = [grb_model.addVar(lb=0, ub=1) for j in range(pts_per_obstacle)]
    vs = [grb_model.addVar(lb=-gurobipy.GRB.INFINITY, ub=gurobipy.GRB.INFINITY) for j in range(dim)]
    grb_model.update()
    for j in range(dim):
        grb_model.addConstr(gurobipy.LinExpr(list(ys[j,:]), ws) == vs[j])
    grb_model.addConstr(gurobipy.quicksum(ws) == 1)
    grb_model.setObjective(gurobipy.quicksum([vs[j] * vs[j] for j in range(dim)]))

    grb_model.optimize()
    return np.array([v.x for v in vs])

