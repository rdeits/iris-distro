#include <iostream>
#include "iris.hpp"
#include "iris_mosek.hpp"
#include "iris/cvxgen_ldp.hpp"

using namespace Eigen;

// valuecheck() and valuecheckMatrix are taken from the open-source Drake toolbox for planning and control: http://drake.mit.edu
template <typename T>
void valuecheck(const T& a, const T& b)
{
  if (a != b) {
    std::ostringstream stream;
    stream << "Expected:\n" << a << "\nbut got:" << b << "\n";
    throw std::runtime_error(stream.str());
  }
}

template<typename Derived>
std::string to_string(const Eigen::MatrixBase<Derived> & a)
{
  std::stringstream ss;
  ss << a;
  return ss.str();
}

inline bool isNaN(double x) {
#ifdef WIN32
  return _isnan(x) != 0;
#else
  return std::isnan(x);
#endif
}

template<typename DerivedA, typename DerivedB>
void valuecheckMatrix(const Eigen::MatrixBase<DerivedA>& a, const Eigen::MatrixBase<DerivedB>& b, double tol, std::string error_msg = "")
{
  // note: isApprox uses the L2 norm, so is bad for comparing against zero
  if (a.rows() != b.rows() || a.cols() != b.cols()) {
    throw std::runtime_error(
        "Drake:ValueCheck ERROR:" + error_msg + "size mismatch: (" + std::to_string(static_cast<unsigned long long>(a.rows())) + " by " + std::to_string(static_cast<unsigned long long>(a.cols())) + ") and (" + std::to_string(static_cast<unsigned long long>(b.rows())) + " by "
            + std::to_string(static_cast<unsigned long long>(b.cols())) + ")");
  }
  if (!(a - b).isZero(tol)) {
    if (!a.allFinite() && !b.allFinite()) {
      // could be failing because inf-inf = nan
      bool ok = true;
      for (int i = 0; i < a.rows(); i++)
        for (int j = 0; j < a.cols(); j++) {
          bool both_positive_infinity = a(i, j) == std::numeric_limits<double>::infinity() && b(i, j) == std::numeric_limits<double>::infinity();
          bool both_negative_infinity = a(i, j) == -std::numeric_limits<double>::infinity() && b(i, j) == -std::numeric_limits<double>::infinity();
          bool both_nan = std::isnan(a(i, j)) && std::isnan(b(i, j));
          ok = ok && (both_positive_infinity || both_negative_infinity || (both_nan) || (std::abs(a(i, j) - b(i, j)) < tol));
        }
      if (ok)
        return;
    }
    error_msg += "A:\n" + to_string(a) + "\nB:\n" + to_string(b) + "\n";
    throw std::runtime_error("Drake:ValueCheck ERROR:" + error_msg);
  }
}

void test_append_polytope() {

  MatrixXd A(3,2);
  A << -1, 0,
       0, -1,
       1, 1;
  VectorXd b(3);
  b << 0, 0, 1;
  Polytope p(A, b);

  MatrixXd A2(2,2);
  A2 << 2, 3,
        4, 5;
  VectorXd b2(2);
  b2 << 6, 7;
  Polytope other(A2, b2);

  p.appendConstraints(other);

  valuecheck(p.getNumberOfConstraints(), 5);
  MatrixXd A_expected(5,2);
  A_expected << -1, 0,
                 0, -1,
                 1, 1,
                 2, 3,
                 4, 5;
  valuecheckMatrix(p.A, A_expected, 1e-12);
  printf("test_append_polytope passed\n");
}

void test_mosek_ellipsoid() {
  MatrixXd A(3,2);
  A << -1, 0,
        0, -1,
        1, 1;
  VectorXd b(3);
  b << 0, 0, 1;
  Polytope polytope(A, b);

  Ellipsoid ellipsoid(2);

  iris_mosek::inner_ellipsoid(polytope, ellipsoid);

  MatrixXd C_expected(2,2);
  C_expected << 0.332799, -0.132021,
                -0.132021, 0.332799;
  VectorXd d_expected(2);
  d_expected << 0.358029, 0.358029;
  valuecheckMatrix(ellipsoid.C, C_expected, 1e-5);
  valuecheckMatrix(ellipsoid.d, d_expected, 1e-5);

  printf("test_mosek_ellipsoid passed\n");
}

void test_infeasible_ellipsoid() {
  MatrixXd A(3,2);
  A << -1, 0,
        0, -1,
        1, 1;
  VectorXd b(3);
  b << 0, 0, -1;
  Polytope polytope(A, b);

  Ellipsoid ellipsoid(2);

  
  try {
    iris_mosek::inner_ellipsoid(polytope, ellipsoid);
  } catch (iris_mosek::InnerEllipsoidInfeasibleError &e) {
    printf("test_infeasble_ellipsoid passed\n");
    return;
  }
  throw(std::runtime_error("expected an infeasible ellipsoid error"));
}

void test_closest_point() {
  MatrixXd points(2, 4);
  points << 0, 0, 1, 1,
            0, 1, 0, 1;
  VectorXd result(2);
  VectorXd expected(2);
  expected << 0, 0;
  iris_mosek::closest_point_in_convex_hull(points, result);
  valuecheckMatrix(result, expected, 1e-6);

  iris_cvxgen::closest_point_in_convex_hull(points, result);
  valuecheckMatrix(result, expected, 1e-2);

  points << -2, -1, -1, 0,
            -1, -2, 0,  -1;
  expected << -0.5, -0.5;
  iris_mosek::closest_point_in_convex_hull(points, result);
  valuecheckMatrix(result, expected, 1e-6);

  iris_cvxgen::closest_point_in_convex_hull(points, result);
  valuecheckMatrix(result, expected, 1e-2);

  MatrixXd line(2,2);
  line << 9000, 9000,
          -1000, 9000;
  iris_cvxgen::closest_point_in_convex_hull(line, result);
  expected << 9000, 0;
  valuecheckMatrix(result, expected, 1);

  printf("test closest point passed\n");
}

void test_separating_hyperplanes() {
  // A simple example with a sphere centered at the origin
  MatrixXd C(2,2);
  C << 1, 0,
       0, 1;
  VectorXd d(2);
  d << 0, 0;
  Ellipsoid ellipsoid(C, d);

  MatrixXd obs(2,4);
  obs << 2, 3, 3, 2,
         2, 2, 3, 3;
  std::vector<MatrixXd> obstacles;
  obstacles.push_back(obs);

  Polytope result(2);
  bool infeasible_start;
  separating_hyperplanes(obstacles, ellipsoid, result, infeasible_start);
  valuecheck(infeasible_start, false);
  MatrixXd A_expected(1, 2);
  A_expected << 1/std::sqrt(2), 1/std::sqrt(2);
  VectorXd b_expected(1);
  b_expected << 2.0 * 2.0 * 1.0/std::sqrt(2);
  valuecheckMatrix(result.A, A_expected, 1e-6);
  valuecheckMatrix(result.b, b_expected, 1e-6);

  printf("test_separating_hyperplanes passed\n");
}

void test_iris() {
  MatrixXd obs(2,2);
  std::vector<MatrixXd> obstacles;

  // Inflate a region inside a 1x1 box
  obs << 0, 1,
         0, 0;
  obstacles.push_back(obs);
  obs << 1, 1,
         0, 1;
  obstacles.push_back(obs);
  obs << 1, 0,
         1, 1;
  obstacles.push_back(obs);
  obs << 0, 0,
         1, 0;
  obstacles.push_back(obs);

  IRISProblem problem(2);
  problem.start << 0.1, 0.1;
  problem.obstacle_pts = obstacles;

  IRISOptions options;

  IRISRegion region = inflate_region(problem, options);
  MatrixXd C_expected(2,2);
  VectorXd d_expected(2);
  C_expected << 0.5, 0, 
                0, 0.5;
  d_expected << 0.5, 0.5;
  valuecheckMatrix(region.ellipsoid.C, C_expected, 1e-3);
  valuecheckMatrix(region.ellipsoid.d, d_expected, 1e-3);

  printf("test_iris passed\n");
}

int main() {
  test_append_polytope();
  test_mosek_ellipsoid();
  test_infeasible_ellipsoid();
  test_closest_point();
  test_separating_hyperplanes();
  test_iris();
  return 0;
}
