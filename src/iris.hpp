#ifndef _IRIS_H
#define _IRIS_H

#include "iris_types.hpp"

IRISRegion inflate_region(const IRISProblem &problem, const IRISOptions &options, IRISDebugData *debug=NULL);

void separating_hyperplanes(const std::vector<Eigen::MatrixXd> obstacle_pts, const Ellipsoid &ellipsoid, Polytope &polytope, bool &infeasible_start);

#endif