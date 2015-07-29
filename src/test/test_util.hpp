#include <iostream>
#include <stdexcept>
#include <Eigen/Core>

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