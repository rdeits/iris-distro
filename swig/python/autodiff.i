
%{
#ifdef SWIGPYTHON
  #define SWIG_FILE_WITH_INIT
  #include <Python.h>
#endif
#include <unsupported/Eigen/AutoDiff>
#include <iostream>
%}

%include "eigen.i"

%fragment("AutoDiff_Fragments", "header", fragment="Eigen_Fragments") 
%{
  int PyObject_obeys_taylorvar_interface(PyObject* obj) {
    if (!PyObject_HasAttrString(obj, "value")) {
      return 0;
    } else if (!PyObject_HasAttrString(obj, "derivatives")) {
      return 0;
    } else {
      return 1;
    }
  }


  template<typename DerType, int ColsAtCompileTime>
  bool ConvertFromTaylorVarToAutoDiffMatrix(PyObject* in, Eigen::MatrixBase<Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, Eigen::Dynamic, ColsAtCompileTime> > *out) {
    PyObject * value = PyObject_GetAttrString(in, "value");
    int value_array_is_new_object = 0;
    PyArrayObject* value_array = obj_to_array_allow_conversion(value, NPY_DOUBLE, &value_array_is_new_object);
    if (!value_array) {
      std::cout << "could not convert value to double array" << std::endl;
      return false;
    }
    PyObject* derivatives = PyObject_GetAttrString(in, "derivatives");
    if (!derivatives || !PySequence_Check(derivatives) || PyObject_Length(derivatives) == 0) {
      std::cout << "could not get non-empty derivatives property" << std::endl;
      return false;
    }
    PyObject* first_derivatives = PySequence_GetItem(derivatives, 0);
    if (!first_derivatives) {
      std::cout << "could not get first derivatives" << std::endl;
      return false;
    }
    PyArrayObject* derivatives_array = obj_to_array_no_conversion(first_derivatives, NPY_OBJECT);
    if (!derivatives_array) {
      std::cout << "could not convert derivatives to object array" << std::endl;
      return false;
    }

    int m = PyArray_DIM(value_array, 0);
    int n;
    int ndim = PyArray_NDIM(value_array);
    if (PyArray_NDIM(derivatives_array) != ndim) {
      std::cout << "ndim of value and derivatives[0] must match" << std::endl;
      return false;
    }
    for (int i=0; i < ndim; i++) {
      if (PyArray_DIM(value_array, i) != PyArray_DIM(derivatives_array, i)) {
        std::cout << "dimensions of value and derivatives[0] must match" << std::endl;
        return false;
      }
    }
    if (ndim > 2 || ndim < 1) {
      std::cout << "ndim must be 1 or 2" << std::endl;
      return false;
    }
    if (ndim > 1) {
      n = PyArray_DIM(value_array, 1);
    } else {
      n = 1;
    }

    // Eigen::Matrix<Eigen::AutoDiffScalar<Eigen::VectorXd>, Eigen::Dynamic, Eigen::Dynamic> res(m, n);
    out->derived().resize(m, n);
    for (size_t i=0; i < m; i++) {
      for (size_t j = 0; j < n; j++) {
        PyArrayObject* d;
        double* v;
        if (ndim == 1) {
          v = (double*) PyArray_GETPTR1(value_array, i);
          d = obj_to_array_no_conversion(*((PyObject**) PyArray_GETPTR1(derivatives_array, i)), NPY_DOUBLE);
        } else {
          v = (double*) PyArray_GETPTR2(value_array, i, j);
          d = obj_to_array_no_conversion(*((PyObject**) PyArray_GETPTR2(derivatives_array, i, j)), NPY_DOUBLE);
        }
        if (!d || PyArray_NDIM(d) != 1) {
          std::cout << "could not convert derivative at i: " << i << " j: " << j << " to double array" << std::endl;
          return false;
        }

        Eigen::VectorXd derivatives(PyArray_DIM(d, 0));
        for (size_t k=0; k < PyArray_DIM(d, 0); k++) {
          derivatives(k) = *((double*) PyArray_GETPTR1(d, k));
        }
        out->coeffRef(i,j) = Eigen::AutoDiffScalar<Eigen::VectorXd>(*v, derivatives);
        // std::cout << "i: " << i << " j: " << j << " v: " << *v << " res(i,j): " << res(i,j).value() << std::endl;
      }
    }

    Py_DECREF(value);
    Py_DECREF(derivatives);
    Py_DECREF(first_derivatives);
    if (value_array_is_new_object) {
      Py_DECREF(value_array);
    }
    return true;

  }
  // template <typename DerType>
  // bool ConvertFromTaylorVarToAutoDiffMatrix(Eigen::MatrixBase<Eigen::AutoDiffScalar<DerType>, Eigen::Dynamic, Eigen::Dynamic

  template<typename DerType, int ColsAtCompileTime>
  bool ConvertFromAutoDiffMatrixToTaylorVar(Eigen::MatrixBase<Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, Eigen::Dynamic, ColsAtCompileTime> >* in, PyObject** out) {
    if (!out) {
      std::cout << "output pointer was null" << std::endl;
      return false;
    }

    size_t m = in->rows();
    size_t n = in->cols();

    PyObject* sys_mod_dict = PyImport_GetModuleDict();
    if (!sys_mod_dict) {
      std::cout << "could not get sys mod dict" << std::endl;
      return false;
    }
    PyObject* taylor_mod = PyMapping_GetItemString(sys_mod_dict, "taylor");
    if (!taylor_mod) {
      std::cout << "could not get taylor module" << std::endl;
      return false;
    }

    PyObject* value;
    PyObject* first_derivatives;
    if (ColsAtCompileTime == 1) {
      npy_intp dims[] = {m};
      value = PyArray_SimpleNew(1, dims, NPY_DOUBLE);
      first_derivatives = PyArray_SimpleNew(1, dims, NPY_OBJECT);
    } else {
      npy_intp dims[] = {m, n};
      value = PyArray_SimpleNew(2, dims, NPY_DOUBLE);
      first_derivatives = PyArray_SimpleNew(2, dims, NPY_OBJECT);
    }
    PyArrayObject* value_array = obj_to_array_no_conversion(value, NPY_DOUBLE);
    PyArrayObject* derivatives_array = obj_to_array_no_conversion(first_derivatives, NPY_OBJECT);

    for (int i=0; i < m; i++) {
      for (int j=0; j < n; j++) {
        double* val;
        PyObject ** der;
        if (ColsAtCompileTime == 1) {
          val = (double*) PyArray_GETPTR1(value_array, i);
          der = (PyObject**) PyArray_GETPTR1(derivatives_array, i);
        } else {
          val = (double*) PyArray_GETPTR2(value_array, i, j);
          der = (PyObject**) PyArray_GETPTR2(derivatives_array, i, j);
        }
        *val = in->coeffRef(i, j).value();
        npy_intp num_derivatives = in->coeffRef(i, j).derivatives().size();
        *der = PyArray_SimpleNew(1, &num_derivatives, NPY_DOUBLE);
        PyArrayObject* d_array = obj_to_array_no_conversion(*der, NPY_DOUBLE);
        for (int k=0; k < num_derivatives; k++) {
          double* d_val = (double*) PyArray_GETPTR1(d_array, k);
          *d_val = in->coeffRef(i, j).derivatives()(k);
        }
      }
    }

    PyObject* derivatives = PyTuple_New(1);
    PyTuple_SetItem(derivatives, 0, first_derivatives);

    *out = PyObject_CallMethodObjArgs(taylor_mod, PyString_FromString("TaylorVar"), value, derivatives, NULL);
    Py_DECREF(value);
    Py_DECREF(derivatives);
    return true;
  }
%}

%define %autodiff_typemaps(Precedence, ColsAtCompileTime, DerType)

%typemap(in, fragment="AutoDiff_Fragments") Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, Eigen::Dynamic, ColsAtCompileTime> {
  std::cout << "running autodiff matrix input typemap" << std::endl;
  if (!ConvertFromTaylorVarToAutoDiffMatrix<DerType, ColsAtCompileTime>($input, &$1)){
    SWIG_fail;
  }
}

%typecheck(Precedence, fragment="AutoDiff_Fragments") 
  Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, Eigen::Dynamic, ColsAtCompileTime> {
  std::cout << "running autodiff ColsAtCompileTime typecheck" << std::endl;

  if (!PyObject_obeys_taylorvar_interface($input)) {
    std::cout << "does not obey taylorvar interface" << std::endl;
    $1 = 0;
  } else {
    PyObject * value = PyObject_GetAttrString($input, "value");
    PyArrayObject* value_array = obj_to_array_no_conversion(value, array_type(value));
    if (!value_array) {
      std::cout << "no value_array" << std::endl;
      $1 = 0;
    } else {
      if (ColsAtCompileTime == -1) {
        $1 = (PyArray_NDIM(value_array) == 2);
      } else if (ColsAtCompileTime == 1) {
        $1 = (PyArray_NDIM(value_array) == 1);
      } else {
        $1 = (PyArray_NDIM(value_array) == 2) && (PyArray_DIM(value_array, 2) == ColsAtCompileTime);
      }

      // $1 = (PyArray_NDIM(value_array) == 1 && 
      // $1 = (PyArray_NDIM(value_array) == 1 || (PyArray_NDIM(value_array) == 2 && PyArray_DIM(value_array, 2) == 1));
      std::cout << "ndim: " << PyArray_NDIM(value_array) << std::endl;
    }
    Py_DECREF(value);
  }
}


%typemap(out, fragment="AutoDiff_Fragments") Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, Eigen::Dynamic, ColsAtCompileTime> {
  std::cout << "running autodiff matrix output map" << std::endl;
  if (!ConvertFromAutoDiffMatrixToTaylorVar<DerType, ColsAtCompileTime>(&$1, &$result)) {
    SWIG_fail;
  }
}

%enddef

