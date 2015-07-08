#include <Eigen/Core>

Eigen::MatrixXd copyToMatrix(double *data, int rows, int cols) {
  Eigen::MatrixXd result(rows, cols);
  new (&result) Eigen::Map<Eigen::MatrixXd>(data, rows, cols);
  return result;
}

Eigen::VectorXd copyToVector(double *data, int size) {
  Eigen::VectorXd result(size);
  new (&result) Eigen::Map<Eigen::VectorXd>(data, size);
  return result;
}