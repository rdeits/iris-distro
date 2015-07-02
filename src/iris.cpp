#include <iostream>
#include <numeric>
#include <Eigen/LU>
#include "iris.hpp"
#include "iris_mosek.hpp"
#include "iris/cvxgen_ldp.hpp"

using namespace Eigen;

void initialize_small_sphere(const VectorXd &start, Ellipsoid &ellipsoid) {
  assert(ellipsoid.getDimension() == start.size());
  ellipsoid.d = start;
  for (int i=0; i < ellipsoid.getDimension(); i++) {
    ellipsoid.C(i,i) = ELLIPSOID_C_EPSILON;
  }
}

template <typename T>
std::vector<size_t> arg_sort(const std::vector<T> &vec) {
  std::vector<size_t> idx(vec.size());
  std::iota(idx.begin(), idx.end(), 0);
  std::sort(idx.begin(), idx.end(), [&vec](size_t i0, size_t i1) {return vec[i0] < vec[i1];});
  return idx;
}

typedef std::pair<VectorXd, double> hyperplane;

hyperplane tangent_plane_through_point(const Ellipsoid &ellipsoid, const MatrixXd &Cinv2, const VectorXd &x) {
  VectorXd nhat = (2 * Cinv2 * (x - ellipsoid.d)).normalized();
  std::pair<VectorXd, double> plane(nhat,
                                    nhat.transpose() * x);
  // std::cout << "tangent plane through point: " << x.transpose() << std::endl;
  // std::cout << plane.first.transpose() << " | " << plane.second << std::endl;
  return plane;
}

void choose_closest_point_solver(const MatrixXd &Points, VectorXd &result, MSKenv_t &env) {
  // std::cout << "points: " << std::endl << Points << std::endl;
  if (Points.rows() <= IRIS_CVXGEN_LDP_MAX_ROWS && Points.cols() <= IRIS_CVXGEN_LDP_MAX_COLS) {
    iris_cvxgen::closest_point_in_convex_hull(Points, result);
  } else {
    if (!env) {
      std::cout << "making env" << std::endl;
      iris_mosek::check_res(MSK_makeenv(&env, NULL));
    }
    iris_mosek::closest_point_in_convex_hull(Points, result, &env);
  }
  // std::cout << "closest point: " << result.transpose() << std::endl;
}

void separating_hyperplanes(const std::vector<MatrixXd> obstacle_pts, const Ellipsoid &ellipsoid, Polytope &polytope, bool &infeasible_start) {

  int dim = ellipsoid.getDimension();
  infeasible_start = false;
  int n_obs = obstacle_pts.size();

  if (n_obs == 0) {
    polytope.A = MatrixXd::Zero(0, dim);
    polytope.b = VectorXd::Zero(0);
    return;
  }

  MatrixXd Cinv = ellipsoid.C.inverse();
  MatrixXd Cinv2 = Cinv * Cinv.transpose();

  Matrix<bool, Dynamic, 1> uncovered_obstacles = Matrix<bool, Dynamic, 1>::Constant(n_obs, true);

  std::vector<MatrixXd> image_pts(n_obs);
  for (int i=0; i < n_obs; i++) {
    image_pts[i] = Cinv * (obstacle_pts[i].colwise() - ellipsoid.d);
  }

  std::vector<VectorXd> image_squared_dists(n_obs);
  for (int i=0; i < n_obs; i++) {
    image_squared_dists[i] = image_pts[i].colwise().squaredNorm();
  }

  std::vector<double> obs_min_squared_image_dists(n_obs);
  for (int i=0; i < n_obs; i++) {
    obs_min_squared_image_dists[i] = image_squared_dists[i].minCoeff();
  }
  std::vector<size_t> obs_sort_idx = arg_sort(obs_min_squared_image_dists);

  std::vector<std::pair<VectorXd, double>> planes;

  MSKenv_t env = NULL;
  for (auto it = obs_sort_idx.begin(); it != obs_sort_idx.end(); ++it) {
    size_t i = *it;
    if (!uncovered_obstacles(i)) {
      continue;
    }
    DenseIndex idx;
    image_squared_dists[i].minCoeff(&idx);
    hyperplane plane = tangent_plane_through_point(ellipsoid, Cinv2, obstacle_pts[i].col(idx));
    if ((((plane.first.transpose() * obstacle_pts[i]).array() - plane.second) >= 0).all()) {
      // nhat already separates the ellipsoid from obstacle i, so we can skip the optimization
      planes.push_back(plane);
    } else {
      VectorXd ystar(dim);
      choose_closest_point_solver(image_pts[i], ystar, env);

      if (ystar.squaredNorm() < 1e-6) {
        // d is inside the obstacle. So we'll just reverse nhat to try to push the
        // ellipsoid out of the obstacle.
        infeasible_start = true;
        planes.emplace_back(-plane.first, -plane.first.transpose() * obstacle_pts[i].col(idx));
      } else {
        VectorXd xstar = ellipsoid.C * ystar + ellipsoid.d;
        planes.push_back(tangent_plane_through_point(ellipsoid, Cinv2, xstar));
      }
    }

    for (size_t j=0; j < n_obs; j++) {
      if (((planes.back().first.transpose() * obstacle_pts[j]).array() >= planes.back().second).all()) {
        uncovered_obstacles(j) = false;
      }
    }
    uncovered_obstacles(i) = false; // even if it doesn't pass the strict check, we're done with this obstacle

    if (!uncovered_obstacles.any()) {
      break;
    }
  }

  polytope.A.resize(planes.size(), dim);
  polytope.b.resize(planes.size(), 1);

  for (auto it = planes.begin(); it != planes.end(); ++it) {
    polytope.A.row(it - planes.begin()) = it->first.transpose();
    polytope.b(it - planes.begin()) = it->second;
  }

  return;
}

IRISRegion inflate_region(const IRISProblem &problem, const IRISOptions &options, IRISDebugData *debug) {

  IRISRegion region(problem.getDimension());
  region.ellipsoid = problem.getSeed();

  double best_vol = pow(ELLIPSOID_C_EPSILON, problem.getDimension());
  double volume;
  long int iter = 0;
  bool infeasible_start;

  if (debug) {
    debug->ellipsoid_history.push_back(region.ellipsoid);
    debug->obstacles = std::vector<MatrixXd>(problem.getObstacles().begin(), problem.getObstacles().end());
  }


  while (1) {
    separating_hyperplanes(problem.getObstacles(), region.ellipsoid, region.polytope, infeasible_start);

    // std::cout << "A: " << std::endl << region.polytope.A << std::endl;
    // std::cout << "b: " << region.polytope.b.transpose() << std::endl;

    if (options.error_on_infeas_start && infeasible_start) {
      throw(std::runtime_error("Error: initial point is infeasible\n"));
    }

    region.polytope.appendConstraints(problem.getBounds());

    volume = iris_mosek::inner_ellipsoid(region.polytope, region.ellipsoid);

    if ((abs(volume - best_vol) / best_vol) < options.termination_threshold)
      break;

    best_vol = volume; // always true because ellipsoid volume is guaranteed to be non-decreasing (see Deits14). 
    iter++;
  }

  return region;
}
