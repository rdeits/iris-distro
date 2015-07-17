using namespace Eigen;


Polytope::Polytope(int dim):
  A_(0, dim),
  b_(0, 1) {}
Polytope::Polytope(Eigen::MatrixXd A, Eigen::VectorXd b):
    A_(A),
    b_(b) {}
void Polytope::setA(const Eigen::MatrixXd &A) {
  A_ = A;
  dd_representation_dirty_ = true;
}
const Eigen::MatrixXd& Polytope::getA() const {
  return A_;
}
void Polytope::setB(const Eigen::VectorXd &b) {
  b_ = b;
  dd_representation_dirty_ = true;
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
  dd_representation_dirty_ = true;
}
void Polytope::updateDDRepresentation() {
  generator_points_.clear();
  generator_rays_.clear();
  getGenerators(A_, b_, generator_points_, generator_rays_);
  dd_representation_dirty_ = false;
}
std::vector<VectorXd> Polytope::generatorPoints() {
  if (dd_representation_dirty_) {
    updateDDRepresentation();
  }
  return generator_points_;
}
std::vector<VectorXd> Polytope::generatorRays() {
  if (dd_representation_dirty_) {
    updateDDRepresentation();
  }
  return generator_rays_;
}
