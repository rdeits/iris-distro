#ifndef _IRIS_H
#define _IRIS_H

#include <Eigen/Core>
#include <vector>
#include <memory>
#include <iostream>
#include "geometry.h"

namespace iris {

class IRISOptions {
public:
  // If require_containment is true and required_containment_points is empty,
  // then the IRIS region is required to contain the center of the seed
  // ellipsoid. Otherwise, the IRIS region is required to contain all points
  // in required_containment_points.
  // If require_containment is false, then required_containment_points has no 
  // effect. 
  bool require_containment;
  bool error_on_infeasible_start;
  double termination_threshold;
  int iter_limit;
  std::vector<Eigen::VectorXd> required_containment_points;

  IRISOptions():
    require_containment(false),
    required_containment_points({}),
    error_on_infeasible_start(false),
    termination_threshold(2e-2),
    iter_limit(100) {};
};

class IRISRegion {
public:
  Polyhedron polyhedron;
  Ellipsoid ellipsoid;

  Polyhedron getPolyhedron() {
    return polyhedron;
  }

  Ellipsoid getEllipsoid() {
    return ellipsoid;
  }

  IRISRegion(int dim=0):
    polyhedron(dim),
    ellipsoid(dim)
    {}
};

class IRISDebugData {
public:
  IRISDebugData() {};
  std::vector<Ellipsoid> ellipsoid_history;
  std::vector<Polyhedron> polyhedron_history;
  std::vector<Eigen::MatrixXd> obstacles;
  std::vector<Eigen::MatrixXd> getObstacles() const {
    return obstacles;
  }
  Polyhedron bounds;
  // Eigen::VectorXd ellipsoid_times;
  // Eigen::VectorXd polyhedron_times;
  // double total_time;
  int iters;

  std::vector<Eigen::VectorXd> boundingPoints() {
    return bounds.generatorPoints();
  }
};

class IRISProblem {
private:
  std::vector<Eigen::MatrixXd> obstacle_pts; // each obstacle is a matrix of size (_dim, pts_per_obstacle)
  Polyhedron bounds;
  int dim;
  Ellipsoid seed;

public:
  IRISProblem(int dim):
    bounds(dim),
    dim(dim),
    seed(dim) {
    }

  void setSeedPoint(Eigen::VectorXd point);
  void setSeedEllipsoid(Ellipsoid ellipsoid);
  int getDimension() const;
  Ellipsoid getSeed() const;
  void setBounds(Polyhedron new_bounds);
  void addObstacle(Eigen::MatrixXd new_obstacle_vertices);
  const std::vector<Eigen::MatrixXd>& getObstacles() const;
  Polyhedron getBounds() const;
};

IRISRegion inflate_region(const IRISProblem &problem, const IRISOptions &options, IRISDebugData *debug=NULL);

void separating_hyperplanes(const std::vector<Eigen::MatrixXd> obstacle_pts, const Ellipsoid &ellipsoid, Polyhedron &polyhedron, bool &infeasible_start);

void getGenerators(const Eigen::MatrixXd &A, const Eigen::VectorXd &b, std::vector<Eigen::VectorXd> &points, std::vector<Eigen::VectorXd> &rays);

class InitialPointInfeasibleError: public std::exception {
  const char * what () const throw () {
    return "Initial point is infeasible";
  }
};

}

#endif