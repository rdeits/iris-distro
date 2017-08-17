#ifndef _IRIS_MOSEK_H
#define _IRIS_MOSEK_H

#include <exception>
#include <mosek.h>
#include "geometry.h"

namespace iris_mosek {

class IRISMosekError : public std::exception {
private:
  std::string message;
public:
  explicit IRISMosekError(MSKrescodee res) {
    /* In case of an error print error code and description. */       
    char symname[MSK_MAX_STR_LEN]; 
    char desc[MSK_MAX_STR_LEN]; 
    MSK_getcodedesc (res, 
                     symname, 
                     desc); 
    message = std::string(symname) + ": " + std::string(desc);
  }

  const char * what () const throw () {
    return message.c_str();
  }
  ~IRISMosekError() throw() {}
};

class InnerEllipsoidInfeasibleError: public std::exception {
  const char * what () const throw () {
    return "Inner ellipsoid problem is infeasible (this likely means that the polyhedron has no interior)";
  }
};

double inner_ellipsoid(const iris::Polyhedron &polyhedron, iris::Ellipsoid *ellipsoid, MSKenv_t *existing_env=NULL);

void closest_point_in_convex_hull(const Eigen::MatrixXd &Points, Eigen::VectorXd &result, MSKenv_t *existing_env=NULL);

void check_res(MSKrescodee res);

}

#endif
