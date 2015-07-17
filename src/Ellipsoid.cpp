using namespace Eigen;

int factorial(int n) {
  return n == 0 ? 1 : factorial(n - 1) * n;
}

double nSphereVolume(int dim, double radius) {
  double v;
  int k = std::floor(dim / 2);
  if (dim % 2 == 0) {
    v = std::pow(M_PI, k) / static_cast<double>(factorial(k));
  } else {
    v = (2.0 * factorial(k) * std::pow(4 * M_PI, k)) / static_cast<double>(factorial(2 * k + 1));
  }
  return v * std::pow(radius, dim);
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
double Ellipsoid::getVolume() const {
  return C_.determinant() * nSphereVolume(this->getDimension(), 1.0);
}
std::shared_ptr<Ellipsoid> Ellipsoid::fromNSphere(Eigen::VectorXd &center, double radius) {
  const int dim = center.size();
  MatrixXd C = MatrixXd::Zero(dim, dim);
  C.diagonal().setConstant(radius);
  std::shared_ptr<Ellipsoid> ellipsoid(new Ellipsoid(C, center));
  return ellipsoid;
}