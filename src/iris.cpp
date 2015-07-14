#include <iostream>
#include <numeric>
#include <Eigen/LU>
#include "iris.hpp"
#include "iris_mosek.hpp"
#include "iris/cvxgen_ldp.hpp"

using namespace Eigen;


Polytope::Polytope(int dim):
  A_(0, dim),
  b_(0, 1) {}
Polytope::Polytope(Eigen::MatrixXd A, Eigen::VectorXd b):
    A_(A),
    b_(b) {}
void Polytope::setA(const Eigen::MatrixXd &A) {
  A_ = A;
}
const Eigen::MatrixXd& Polytope::getA() const {
  return A_;
}
void Polytope::setB(const Eigen::VectorXd &b) {
  b_ = b;
}
const Eigen::VectorXd& Polytope::getB() const {
  return b_;
}
int Polytope::getDimension() const {
  return A_.cols();
}
int Polytope::getNumberOfConstraints() const {
  return A_.rows();
}
void Polytope::appendConstraints(const Polytope &other) {
  A_.conservativeResize(A_.rows() + other.getA().rows(), A_.cols());
  A_.bottomRows(other.getA().rows()) = other.getA();
  b_.conservativeResize(b_.rows() + other.getB().rows());
  b_.tail(other.getB().rows()) = other.getB();
}

Ellipsoid::Ellipsoid(int dim) :
  C_(Eigen::MatrixXd(dim, dim)),
  d_(Eigen::VectorXd(dim)) {}
Ellipsoid::Ellipsoid(Eigen::MatrixXd C, Eigen::VectorXd d):
  C_(C),
  d_(d) {}
const MatrixXd& Ellipsoid::getC() const {
  return C_;
}
const VectorXd& Ellipsoid::getD() const {
  return d_;
}
void Ellipsoid::setC(const Eigen::MatrixXd &C) {
  C_ = C;
}
void Ellipsoid::setCEntry(Eigen::DenseIndex row, 
                          Eigen::DenseIndex col, double value) {
  C_(row, col) = value;
}
void Ellipsoid::setD(const Eigen::VectorXd &d) {
  d_ = d;
}
void Ellipsoid::setDEntry(Eigen::DenseIndex index, double value) {
  d_(index) = value;
}
int Ellipsoid::getDimension() const {
  return C_.cols();
}
std::shared_ptr<Ellipsoid> Ellipsoid::fromNSphere(Eigen::VectorXd &center, double radius) {
  const int dim = center.size();
  MatrixXd C = MatrixXd::Zero(dim, dim);
  C.diagonal().setConstant(radius);
  std::shared_ptr<Ellipsoid> ellipsoid(new Ellipsoid(C, center));
  return ellipsoid;
}

void IRISProblem::setSeedPoint(Eigen::VectorXd point) {
  if (point.size() != this->getDimension()) {
    throw(std::runtime_error("seed point must match dimension dim"));
  }
  this->seed = *Ellipsoid::fromNSphere(point);
}
void IRISProblem::setSeedEllipsoid(Ellipsoid ellipsoid){
  if (ellipsoid.getDimension() != this->getDimension()) {
    throw std::runtime_error("seed ellipsoid must match dimension dim");
  }
  this->seed = ellipsoid;
}
int IRISProblem::getDimension() const {
  return this->dim;
}
Ellipsoid IRISProblem::getSeed() const {
  return this->seed;
}
void IRISProblem::setBounds(Polytope new_bounds) {
  if (new_bounds.getDimension() != this->getDimension()) {
    throw std::runtime_error("bounds must match dimension dim");
  }
  this->bounds = new_bounds;
}
void IRISProblem::addObstacle(Eigen::MatrixXd new_obstacle_vertices) {
  std::cout << "adding obstacle: " << new_obstacle_vertices << std::endl;
  std::cout << "dim: " << this->getDimension() << std::endl;
  if (new_obstacle_vertices.rows() != this->getDimension()) {
    throw std::runtime_error("new_obstacle_vertices must have dim rows");
  }
  this->obstacle_pts.push_back(new_obstacle_vertices);
}
std::vector<Eigen::MatrixXd> IRISProblem::getObstacles() const {
  return this->obstacle_pts;
}
Polytope IRISProblem::getBounds() const {
  return this->bounds;
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
  VectorXd nhat = (2 * Cinv2 * (x - ellipsoid.getD())).normalized();
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
    polytope.setA(MatrixXd::Zero(0, dim));
    polytope.setB(VectorXd::Zero(0));
    return;
  }

  MatrixXd Cinv = ellipsoid.getC().inverse();
  MatrixXd Cinv2 = Cinv * Cinv.transpose();

  Matrix<bool, Dynamic, 1> uncovered_obstacles = Matrix<bool, Dynamic, 1>::Constant(n_obs, true);

  std::vector<MatrixXd> image_pts(n_obs);
  for (int i=0; i < n_obs; i++) {
    image_pts[i] = Cinv * (obstacle_pts[i].colwise() - ellipsoid.getD());
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
        VectorXd xstar = ellipsoid.getC() * ystar + ellipsoid.getD();
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

  MatrixXd A = polytope.getA();
  VectorXd b = polytope.getB();
  A.resize(planes.size(), dim);
  b.resize(planes.size(), 1);

  for (auto it = planes.begin(); it != planes.end(); ++it) {
    A.row(it - planes.begin()) = it->first.transpose();
    b(it - planes.begin()) = it->second;
  }
  polytope.setA(A);
  polytope.setB(b);

  return;
}

std::shared_ptr<IRISRegion> inflate_region(const IRISProblem &problem, const IRISOptions &options, IRISDebugData *debug) {

  assert(region.polytope->getDimension() == problem.getDimension());
  assert(region.ellipsoid->getDimension() == problem.getDimension());

  std::shared_ptr<IRISRegion> region(new IRISRegion(problem.getDimension()));
  region->ellipsoid->setC(problem.getSeed().getC());
  region->ellipsoid->setD(problem.getSeed().getD());

  double best_vol = pow(ELLIPSOID_C_EPSILON, problem.getDimension());
  double volume;
  long int iter = 0;
  bool infeasible_start;

  if (debug) {
    debug->ellipsoid_history.push_back(*(region->ellipsoid));
    debug->obstacles = std::vector<MatrixXd>(problem.getObstacles().begin(), problem.getObstacles().end());
  }


  while (1) {
    std::cout << "calling hyperplanes with: " << std::endl;
    std::cout << "C: " << region->ellipsoid->getC() << std::endl;
    std::cout << "d: " << region->ellipsoid->getD() << std::endl;
    separating_hyperplanes(problem.getObstacles(), *region->ellipsoid, *region->polytope, infeasible_start);

    // std::cout << "A: " << std::endl << region->polytope.A << std::endl;
    // std::cout << "b: " << region->polytope.b.transpose() << std::endl;

    if (options.error_on_infeasible_start && infeasible_start) {
      throw(std::runtime_error("Error: initial point is infeasible\n"));
    }

    if (options.require_containment && !(iter == 0 || infeasible_start)) {
      throw(std::runtime_error("Not implemented yet"));
    }

    region->polytope->appendConstraints(problem.getBounds());

    std::cout << "calling inner_ellipsoid with: " << std::endl;
    std::cout << "A: " << region->polytope->getA() << std::endl;
    std::cout << "b: " << region->polytope->getB() << std::endl;
    volume = iris_mosek::inner_ellipsoid(*region->polytope, *region->ellipsoid);

    if (iter + 1 >= options.iter_limit || ((abs(volume - best_vol) / best_vol) < options.termination_threshold))
      break;

    best_vol = volume; // always true because ellipsoid volume is guaranteed to be non-decreasing (see Deits14). 
    iter++;
  }

  return region;
}
