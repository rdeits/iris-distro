using namespace Eigen;

namespace iris {

Polyhedron::Polyhedron(int dim):
  A_(0, dim),
  b_(0, 1) {}
Polyhedron::Polyhedron(Eigen::MatrixXd A, Eigen::VectorXd b):
    A_(A),
    b_(b) {}
void Polyhedron::setA(const Eigen::MatrixXd &A) {
  A_ = A;
  dd_representation_dirty_ = true;
}
const Eigen::MatrixXd& Polyhedron::getA() const {
  return A_;
}
void Polyhedron::setB(const Eigen::VectorXd &b) {
  b_ = b;
  dd_representation_dirty_ = true;
}
const Eigen::VectorXd& Polyhedron::getB() const {
  return b_;
}
int Polyhedron::getDimension() const {
  return A_.cols();
}
int Polyhedron::getNumberOfConstraints() const {
  return A_.rows();
}
void Polyhedron::appendConstraints(const Polyhedron &other) {
  A_.conservativeResize(A_.rows() + other.getA().rows(), A_.cols());
  A_.bottomRows(other.getA().rows()) = other.getA();
  b_.conservativeResize(b_.rows() + other.getB().rows());
  b_.tail(other.getB().rows()) = other.getB();
  dd_representation_dirty_ = true;
}
void Polyhedron::updateDDRepresentation() {
  generator_points_.clear();
  generator_rays_.clear();
  getGenerators(A_, b_, generator_points_, generator_rays_);
  dd_representation_dirty_ = false;
}
std::vector<VectorXd> Polyhedron::generatorPoints() {
  if (dd_representation_dirty_) {
    updateDDRepresentation();
  }
  return generator_points_;
}
std::vector<VectorXd> Polyhedron::generatorRays() {
  if (dd_representation_dirty_) {
    updateDDRepresentation();
  }
  return generator_rays_;
}
bool Polyhedron::contains(VectorXd point, double tolerance) {
  return (A_ * point - b_).maxCoeff() <= tolerance;
}

}