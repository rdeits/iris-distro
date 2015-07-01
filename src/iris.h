#include "iris_util.h"

IRISRegion inflate_region(const IRISProblem &problem, const IRISOptions &options, IRISDebugData *debug=NULL);

void separating_hyperplanes(const std::vector<Eigen::MatrixXd> obstacle_pts, const Ellipsoid &ellipsoid, Polytope &polytope, bool &infeasible_start);

void closest_point_in_convex_hull_cvxgen(Eigen::MatrixXd Points, Eigen::VectorXd &result);
