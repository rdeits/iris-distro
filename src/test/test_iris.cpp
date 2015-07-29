#include <iostream>
#include "test_util.hpp"
#include "iris/iris.hpp"
#include "iris/iris_mosek.hpp"
#include "iris/cvxgen_ldp.hpp"

using namespace Eigen;
using namespace iris;

void test_append_polyhedron() {

  MatrixXd A(3,2);
  A << -1, 0,
       0, -1,
       1, 1;
  VectorXd b(3);
  b << 0, 0, 1;
  Polyhedron p(A, b);

  MatrixXd A2(2,2);
  A2 << 2, 3,
        4, 5;
  VectorXd b2(2);
  b2 << 6, 7;
  Polyhedron other(A2, b2);

  p.appendConstraints(other);

  valuecheck(p.getNumberOfConstraints(), 5);
  MatrixXd A_expected(5,2);
  A_expected << -1, 0,
                 0, -1,
                 1, 1,
                 2, 3,
                 4, 5;
  valuecheckMatrix(p.getA(), A_expected, 1e-12);
  printf("test_append_polyhedron passed\n");
}

void test_mosek_ellipsoid() {
  MatrixXd A(3,2);
  A << -1, 0,
        0, -1,
        1, 1;
  VectorXd b(3);
  b << 0, 0, 1;
  Polyhedron polyhedron(A, b);

  Ellipsoid ellipsoid(2);

  iris_mosek::inner_ellipsoid(polyhedron, &ellipsoid);

  MatrixXd C_expected(2,2);
  C_expected << 0.332799, -0.132021,
                -0.132021, 0.332799;
  VectorXd d_expected(2);
  d_expected << 0.358029, 0.358029;
  valuecheckMatrix(ellipsoid.getC(), C_expected, 1e-5);
  valuecheckMatrix(ellipsoid.getD(), d_expected, 1e-5);

  printf("test_mosek_ellipsoid passed\n");
}

void test_infeasible_ellipsoid() {
  MatrixXd A(3,2);
  A << -1, 0,
        0, -1,
        1, 1;
  VectorXd b(3);
  b << 0, 0, -1;
  Polyhedron polyhedron(A, b);

  Ellipsoid ellipsoid(2);

  
  try {
    iris_mosek::inner_ellipsoid(polyhedron, &ellipsoid);
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


  MatrixXd points5(5, 32);
  points5 << -1872.48,-1829.59,-1947.79,-1783.39,-1712.13,-1757.48,-1797.66,-1753.24,-1767.25,-1926.22,-1926.78,-1738.69,-1813.46,-1952.15,-1888.93,-1821.83,-1894.04,-1832.17,-1885.76,-1760.49,-1885.13,-1921.02,-1864.35,-1845.11,-1856.77,-1824.37,-1828.71,-1863.75,-1754.67,-1822.5,-1717.14,-1746.51,
-1766.57,-1722.45,-1600.82,-1622.11,-1635.21,-1774.41,-1708.03,-1673.71,-1744.08,-1825.43,-1634.01,-1622.61,-1750.8,-1695.51,-1692.97,-1616.53,-1637.12,-1696.21,-1833.12,-1692.46,-1769.92,-1655.63,-1665.76,-1813.13,-1764.97,-1608.74,-1776.96,-1731.31,-1760.92,-1652.26,-1639.92,-1742.6,
-868.916,-1087.29,-1032.94,-1070.76,-1028.55,-966.867,-941.882,-1062.21,-1090.7,-1097.47,-955.821,-873.972,-969.474,-1039.29,-1067.84,-955.372,-894.304,-901.631,-1088.84,-895.907,-930.735,-1074.37,-889.848,-880.109,-938.567,-1046.24,-1084.81,-994.232,-1006.57,-1048.34,-892.176,-952.407,
2596.61,2527.3,2395.15,2595.03,2446.58,2585.61,2572.42,2362.46,2553.85,2379.93,2471.96,2514.34,2567.2,2476.63,2378.64,2413.77,2398.53,2540.33,2411.03,2514.93,2552.98,2538.95,2580.4,2413.49,2563.99,2543.24,2380.5,2599.27,2389.72,2430.37,2578.74,2520.03,
-680.843,-573.134,-775.128,-723.158,-627.324,-665.019,-608.212,-784.947,-718.664,-747.286,-627.046,-723.587,-572.384,-610.751,-581.003,-623.084,-638.895,-618.737,-682.26,-760.279,-661.069,-661.551,-640.068,-763.236,-601.584,-578.084,-582.512,-711.361,-654.364,-586.518,-666.37,-742.146;
  result.resize(5);
  iris_mosek::closest_point_in_convex_hull(points5, result);

  expected.resize(5);
  expected << -1717.5, -1634.3, -1025.0, 2445.0, -627.1;
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

  Polyhedron result(2);
  bool infeasible_start;
  separating_hyperplanes(obstacles, ellipsoid, result, infeasible_start);
  valuecheck(infeasible_start, false);
  MatrixXd A_expected(1, 2);
  A_expected << 1/std::sqrt(2), 1/std::sqrt(2);
  VectorXd b_expected(1);
  b_expected << 2.0 * 2.0 * 1.0/std::sqrt(2);
  valuecheckMatrix(result.getA(), A_expected, 1e-6);
  valuecheckMatrix(result.getB(), b_expected, 1e-6);

  printf("test_separating_hyperplanes passed\n");
}

void test_iris() {
  IRISProblem problem(2);
  problem.setSeedPoint(Vector2d(0.1, 0.1));

  MatrixXd obs(2,2);
  // Inflate a region inside a 1x1 box
  obs << 0, 1,
         0, 0;
  problem.addObstacle(obs);
  obs << 1, 1,
         0, 1;
  problem.addObstacle(obs);
  obs << 1, 0,
         1, 1;
  problem.addObstacle(obs);
  obs << 0, 0,
         1, 0;
  problem.addObstacle(obs);

  IRISOptions options;
  auto region = inflate_region(problem, options);
  MatrixXd C_expected(2,2);
  VectorXd d_expected(2);
  C_expected << 0.5, 0, 
                0, 0.5;
  d_expected << 0.5, 0.5;
  valuecheckMatrix(region->ellipsoid->getC(), C_expected, 1e-3);
  valuecheckMatrix(region->ellipsoid->getD(), d_expected, 1e-3);

  printf("test_iris passed\n");
}

void test_for_thin_mosek_ellipsoid_bug() {
  MatrixXd A(4,3);
  A << -1, 0, 0,
       0, -1, 0,
       0, 0, -1,
       1, 1, 1;
  VectorXd b(4);
  b << 0, 0, 0, 1;
  Polyhedron polyhedron(A, b);

  Ellipsoid ellipsoid(3);

  iris_mosek::inner_ellipsoid(polyhedron, &ellipsoid);

  MatrixXd C_expected(3,3);
  C_expected <<  0.2523,   -0.0740,   -0.0740,
                 -0.0740,    0.2523,   -0.0740,
                 -0.0740,   -0.0740,    0.2523;
  VectorXd d_expected(3);
  d_expected << 0.2732, 0.2732, 0.2732;
  valuecheckMatrix(ellipsoid.getC(), C_expected, 1e-3);
  valuecheckMatrix(ellipsoid.getD(), d_expected, 1e-3);

  std::cout << "test for thin ellipsoid bug passed" << std::endl;
}

int main() {
  test_append_polyhedron();
  test_mosek_ellipsoid();
  test_for_thin_mosek_ellipsoid_bug();
  test_infeasible_ellipsoid();
  test_closest_point();
  test_separating_hyperplanes();
  test_iris();
  return 0;
}
