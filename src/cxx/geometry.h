#ifndef _IRIS_GEOMETRY_H
#define _IRIS_GEOMETRY_H
#include <Eigen/Core>
#include <vector>

namespace iris {

const double ELLIPSOID_C_EPSILON = 1e-4;


class Polyhedron {
public:
  Polyhedron(int dim=0);
  Polyhedron(Eigen::MatrixXd A, Eigen::VectorXd b);
  ~Polyhedron() {
    // std::cout << "deleting polyhedron: " << this << std::endl;
  }
  void setA(const Eigen::MatrixXd &A);
  const Eigen::MatrixXd& getA() const;
  void setB(const Eigen::VectorXd &b);
  const Eigen::VectorXd& getB() const;
  int getDimension() const;
  int getNumberOfConstraints() const;
  void appendConstraints(const Polyhedron &other);
  std::vector<Eigen::VectorXd> generatorPoints();
  std::vector<Eigen::VectorXd> generatorRays();
  bool contains(Eigen::VectorXd point, double tolerance);

private:
  Eigen::MatrixXd A_;
  Eigen::VectorXd b_;
  bool dd_representation_dirty_;
  std::vector<Eigen::VectorXd> generator_points_;
  std::vector<Eigen::VectorXd> generator_rays_;
  void updateDDRepresentation();
};


class Ellipsoid {
public:
  Ellipsoid(int dim=0);
  Ellipsoid(Eigen::MatrixXd C, Eigen::VectorXd d);
  ~Ellipsoid() {
    // std::cout << "deleting ellipsoid: " << this << std::endl;
  }
  const Eigen::MatrixXd& getC() const;
  const Eigen::VectorXd& getD() const;
  void setC(const Eigen::MatrixXd &C_);
  void setCEntry(Eigen::DenseIndex row, Eigen::DenseIndex col, double value);
  void setD(const Eigen::VectorXd &d_);
  void setDEntry(Eigen::DenseIndex idx, double value);
  int getDimension() const;
  static Ellipsoid fromNSphere(Eigen::VectorXd &center, double radius=ELLIPSOID_C_EPSILON);
  double getVolume() const;

private:
  Eigen::MatrixXd C_;
  Eigen::VectorXd d_;
};

}


#endif //def _IRIS_GEOMETRY_H