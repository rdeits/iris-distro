#include "iris_util.h"

IRISRegion* inflate_region(const IRISProblem &problem, const IRISOptions &options, IRISDebugData *debug);

void closest_point_in_convex_hull_cvxgen(Eigen::MatrixXd Points, Eigen::VectorXd &result);
