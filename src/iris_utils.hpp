#include <Eigen/Core>

Eigen::MatrixXd copyToMatrix(double *data, int rows, int cols) {
  Eigen::MatrixXd result(rows, cols);
  for (int i=0; i < rows; i++) {
    for (int j=0; j < cols; j++) {
      result(i, j) = data[i * cols + j];
    }
  }
  return result;
}

Eigen::VectorXd copyToVector(double *data, int size) {
  Eigen::VectorXd result(size);
  for (int i=0; i < size; i++) {
    result(i) = data[i];
  }
  return result;
}