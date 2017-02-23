#include "iris/iris.h"
#include <stdexcept>
#include <iostream>
#include <numeric>
#include <chrono>
#include <Eigen/LU>
#include <Eigen/StdVector>
#include "iris/iris_mosek.h"
#include "cvxgen/iris/cvxgen_ldp.h"

namespace iris {

template <typename T>
std::vector<size_t> arg_sort(const std::vector<T> &vec) {
  std::vector<size_t> idx(vec.size());
  std::iota(idx.begin(), idx.end(), 0);
  std::sort(idx.begin(), idx.end(), [&vec](size_t i0, size_t i1) {return vec[i0] < vec[i1];});
  return idx;
}

typedef std::pair<Eigen::VectorXd, double> hyperplane;

hyperplane tangent_plane_through_point(const Ellipsoid &ellipsoid, const Eigen::MatrixXd &Cinv2, const Eigen::VectorXd &x) {
  Eigen::VectorXd nhat = (2 * Cinv2 * (x - ellipsoid.getD())).normalized();
  std::pair<Eigen::VectorXd, double> plane(nhat,
                                    nhat.transpose() * x);
  // std::cout << "tangent plane through point: " << x.transpose() << std::endl;
  // std::cout << plane.first.transpose() << " | " << plane.second << std::endl;
  return plane;
}

void choose_closest_point_solver(const Eigen::MatrixXd &Points, Eigen::VectorXd &result, MSKenv_t &env) {
  // std::cout << "points: " << std::endl << Points << std::endl;
  if (Points.rows() <= IRIS_CVXGEN_LDP_MAX_ROWS && Points.cols() <= IRIS_CVXGEN_LDP_MAX_COLS) {
    iris_cvxgen::closest_point_in_convex_hull(Points, result);
  } else {
    if (!env) {
      // std::cout << "making env" << std::endl;
      iris_mosek::check_res(MSK_makeenv(&env, NULL));
    }
    iris_mosek::closest_point_in_convex_hull(Points, result, &env);
  }
  // std::cout << "closest point: " << result.transpose() << std::endl;
}

void separating_hyperplanes(const std::vector<Eigen::MatrixXd> obstacle_pts, const Ellipsoid &ellipsoid, Polyhedron &polyhedron, bool &infeasible_start) {

  int dim = ellipsoid.getDimension();
  infeasible_start = false;
  int n_obs = obstacle_pts.size();

  if (n_obs == 0) {
    polyhedron.setA(Eigen::MatrixXd::Zero(0, dim));
    polyhedron.setB(Eigen::VectorXd::Zero(0));
    return;
  }

  Eigen::MatrixXd Cinv = ellipsoid.getC().inverse();
  Eigen::MatrixXd Cinv2 = Cinv * Cinv.transpose();

  Eigen::Matrix<bool, Eigen::Dynamic, 1> uncovered_obstacles = Eigen::Matrix<bool, Eigen::Dynamic, 1>::Constant(n_obs, true);

  std::vector<Eigen::MatrixXd> image_pts(n_obs);
  for (int i=0; i < n_obs; i++) {
    image_pts[i] = Cinv * (obstacle_pts[i].colwise() - ellipsoid.getD());
  }

  std::vector<Eigen::VectorXd> image_squared_dists(n_obs);
  for (int i=0; i < n_obs; i++) {
    image_squared_dists[i] = image_pts[i].colwise().squaredNorm();
  }

  std::vector<double> obs_min_squared_image_dists(n_obs);
  for (int i=0; i < n_obs; i++) {
    obs_min_squared_image_dists[i] = image_squared_dists[i].minCoeff();
  }
  std::vector<size_t> obs_sort_idx = arg_sort(obs_min_squared_image_dists);

  std::vector<std::pair<Eigen::VectorXd, double>> planes;

  MSKenv_t env = NULL;
  for (auto it = obs_sort_idx.begin(); it != obs_sort_idx.end(); ++it) {
    size_t i = *it;
    if (!uncovered_obstacles(i)) {
      continue;
    }
    Eigen::DenseIndex idx;
    image_squared_dists[i].minCoeff(&idx);
    hyperplane plane = tangent_plane_through_point(ellipsoid, Cinv2, obstacle_pts[i].col(idx));
    if ((((plane.first.transpose() * obstacle_pts[i]).array() - plane.second) >= 0).all()) {
      // nhat already separates the ellipsoid from obstacle i, so we can skip the optimization
      planes.push_back(plane);
    } else {
      Eigen::VectorXd ystar(dim);
      choose_closest_point_solver(image_pts[i], ystar, env);

      if (ystar.squaredNorm() < 1e-6) {
        // d is inside the obstacle. So we'll just reverse nhat to try to push the
        // ellipsoid out of the obstacle.
        infeasible_start = true;
        planes.emplace_back(-plane.first, -plane.first.transpose() * obstacle_pts[i].col(idx));
      } else {
        Eigen::VectorXd xstar = ellipsoid.getC() * ystar + ellipsoid.getD();
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

  // Eigen::MatrixXd A = polyhedron.getA();
  // Eigen::VectorXd b = polyhedron.getB();
  // A.resize(planes.size(), dim);
  // b.resize(planes.size(), 1);
  Eigen::MatrixXd A(planes.size(), dim);
  Eigen::VectorXd b(planes.size());

  for (auto it = planes.begin(); it != planes.end(); ++it) {
    A.row(it - planes.begin()) = it->first.transpose();
    b(it - planes.begin()) = it->second;
  }
  polyhedron.setA(A);
  polyhedron.setB(b);

  return;
}

IRISRegion inflate_region(const IRISProblem &problem, const IRISOptions &options, IRISDebugData *debug) {
  // std::cout << "running IRIS with the following inputs: " << std::endl;
  // std::cout << "bounds: " << std::endl << problem.getBounds().getA() << std::endl << problem.getBounds().getB() << std::endl;
  // std::cout << "obstacles: " << std::endl;
  // auto debug_obstacles = problem.getObstacles();
  // for (auto it = debug_obstacles.begin(); it != debug_obstacles.end(); ++it) {
  //   std::cout << *it << std::endl;
  // }

  IRISRegion region(problem.getDimension());
  region.ellipsoid.setC(problem.getSeed().getC());
  region.ellipsoid.setD(problem.getSeed().getD());

  double best_vol = pow(ELLIPSOID_C_EPSILON, problem.getDimension());
  double volume;
  long int iter = 0;
  bool infeasible_start;
  Polyhedron new_poly(problem.getDimension());

  if (debug) {
    // std::cout << "starting debug" << std::endl;
    debug->bounds = problem.getBounds();
    debug->ellipsoid_history.push_back(region.ellipsoid);
    // std::cout << "pushing back obstacles" << std::endl;
    auto obstacles = problem.getObstacles();
    for (auto obs = obstacles.begin(); obs != obstacles.end(); ++obs) {
      // std::cout << "pushing back obstacle: " << *obs << std::endl;
      debug->obstacles.push_back(*obs);
    }
    // debug->obstacles = std::vector<Eigen::MatrixXd>(problem.getObstacles().begin(), problem.getObstacles().end());
  }

  float p_time = 0;
  float e_time = 0;

  while (1) {
    auto begin = std::chrono::high_resolution_clock::now();
    // std::cout << "calling hyperplanes with: " << std::endl;
    // std::cout << "C: " << region.ellipsoid->getC() << std::endl;
    // std::cout << "d: " << region.ellipsoid->getD() << std::endl;
    separating_hyperplanes(problem.getObstacles(), region.ellipsoid, new_poly, infeasible_start);
    auto end = std::chrono::high_resolution_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::duration<float>>(end - begin);
    p_time += elapsed.count();

    if (options.error_on_infeasible_start && infeasible_start) {
      throw(InitialPointInfeasibleError());
    }

    new_poly.appendConstraints(problem.getBounds());

    // std::cout << "A: " << std::endl << new_poly.getA() << std::endl;
    // std::cout << "b: " << new_poly.getB().transpose() << std::endl;

    if (options.require_containment) {
      bool all_points_contained;
      if (options.required_containment_points.size()) {
        all_points_contained = true;
        for (auto pt = options.required_containment_points.begin(); pt != options.required_containment_points.end(); ++pt) {
          if (!new_poly.contains(*pt, 0.0)) {
            all_points_contained = false;
            break;
          }
        }
      } else {
        all_points_contained = new_poly.contains(problem.getSeed().getD(), 0.0);
      }

      if (all_points_contained || infeasible_start) {
        region.polyhedron = new_poly;
        if (debug) {
          debug->polyhedron_history.push_back(new_poly);
        }
      } else {
        std::cout << "breaking early because the start point is no longer contained in the polyhedron" << std::endl;
        return region;
      }
    } else {
      region.polyhedron = new_poly;
      if (debug) {
        debug->polyhedron_history.push_back(new_poly);
      }
    }

    // std::cout << "calling inner_ellipsoid with: " << std::endl;
    // std::cout << "A: " << region.polyhedron->getA() << std::endl;
    // std::cout << "b: " << region.polyhedron->getB() << std::endl;
    begin = std::chrono::high_resolution_clock::now();
    volume = iris_mosek::inner_ellipsoid(region.polyhedron, &region.ellipsoid);
    end = std::chrono::high_resolution_clock::now();
    elapsed = std::chrono::duration_cast<std::chrono::duration<float>>(end - begin);
    e_time += elapsed.count();

    if (debug) {
      debug->ellipsoid_history.push_back(region.ellipsoid);
    }
    // std::cout << "C: " << region.ellipsoid->getC() << std::endl;
    // std::cout << "volume: " << volume << std::endl;
    // std::cout << "det: " << region.ellipsoid->getC().determinant() << std::endl;

    const bool at_iter_limit = (options.iter_limit > 0) && (iter + 1 >= options.iter_limit);
    const bool insufficient_progress = (std::abs(volume - best_vol) / best_vol) < options.termination_threshold;
    if (at_iter_limit || insufficient_progress) {
      // std::cout << "(abs(volume - best_vol) / best_vol): " << (std::abs(volume - best_vol) / best_vol) << std::endl;
      // std::cout << "term thresh: " << options.termination_threshold << std::endl;
      break;
    }

    best_vol = volume; // always true because ellipsoid volume is guaranteed to be non-decreasing (see Deits14). 
    iter++;
    if (debug) {
      debug->iters = iter;
    }
  }

  // std::cout << "c++ p time: " << p_time << std::endl;
  // std::cout << "c++ e time: " << e_time << std::endl;
  // std::cout << "c++ iters: " << iter << std::endl;
  return region;
}

}