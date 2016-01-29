/* Copyright (c) 2015, Robin Deits
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the copyright holder nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * This file is heavily based on "eigen.i" fom The Biomechanical ToolKit
 * Copyright (c) 2009-2013, Arnaud Barré, released under the 3-clause BSD license. 
 */

%{
  #include <Eigen/Core>
  #include <vector>
%}

%fragment("Eigen_Fragments", "header")
%{
  template <typename T> mxClassID MxType() {return mxUNKNOWN_CLASS;};

  template <class Derived>
  bool ConvertFromMatlabToEigenMatrix(Eigen::MatrixBase<Derived>* out, const mxArray* in)
  {
    size_t rows = 0;
    size_t cols = 0;

    // Do a bunch of validation and type checking
    if (!mxIsNumeric(in)) {
      mexPrintf("input is not a matlab numeric array");
      return false;
    } // check data type
    else if (mxGetClassID(in) != MxType<typename Derived::Scalar>()) {
      mexPrintf("Type mismatch between Matlab and Eigen objects.");
      return false;
    }
    // check dimensions
    else if (mxGetNumberOfDimensions(in) > 2) {
      mexPrintf("Eigen only supports 1D or 2D arrays, but I got a Matlab array with more than 2 dimensions");
      return false;
    }
    else if (mxGetNumberOfDimensions(in) == 1) {
      rows = mxGetNumberOfElements(in);
      cols = 1;
      if ((Derived::RowsAtCompileTime != Eigen::Dynamic) && (Derived::RowsAtCompileTime != rows)) {
        mexPrintf("Row dimension mismatch between Matlab and Eigen objects (1D).");
        return false;
      }
      else if ((Derived::ColsAtCompileTime != Eigen::Dynamic) && (Derived::ColsAtCompileTime != 1)) {
        mexPrintf("Column dimension mismatch between Matlab and Eigen objects (1D).");
        return false;
      }
    }
    else if (mxGetNumberOfDimensions(in) == 2) {
      rows = mxGetM(in);
      cols = mxGetN(in);
      if ((Derived::RowsAtCompileTime != Eigen::Dynamic) && (Derived::RowsAtCompileTime != rows)) {
        mexPrintf("Row dimension mismatch between Matlab and Eigen objects (2D).");
        return false;
      }
      else if ((Derived::ColsAtCompileTime != Eigen::Dynamic) && (Derived::ColsAtCompileTime != cols)) {
        mexPrintf("Column dimension mismatch between Matlab and Eigen objects (2D).");
        return false;
      }
    }

    // Extract the data
    out->derived().setZero(rows, cols);
    typename Derived::Scalar* data = static_cast<typename Derived::Scalar*>(mxGetData(in));
    for (size_t i=0; i < rows; i++) {
      for (size_t j=0; j < cols; j++) {
        out->coeffRef(i,j) = data[i + rows*j];
      }
    }

    return true;
  };

  // Copy values from an Eigen matrix into an *existing* Matlab matrix
  template<class Derived>
  bool CopyFromEigenToMatlabMatrix(mxArray* out, Eigen::MatrixBase<Derived>* in) {
    size_t rows;
    size_t cols;

    // check object type
    if (!mxIsNumeric(out)) {
      mexPrintf("Argout matrix must be a numeric matlab matrix");
      return false;
    }
    // check scalar type
    else if (mxGetClassID(out) != MxType<typename Derived::Scalar>()) {
      mexPrintf("Argout matrix data type does not match the scalar type of the Eigen matrix");
      return false;
    }
    else if (mxGetNumberOfDimensions(out) > 2) {
      mexPrintf("I can't handle Matlab matrices with more than 2 dimensions");
      return false;
    }
    rows = mxGetM(out);
    cols = mxGetN(out);

    if ((Derived::RowsAtCompileTime != Eigen::Dynamic) && (Derived::RowsAtCompileTime != rows))
    {
      mexPrintf("Row dimension mismatch between Matlab and Eigen objects");
      return false;
    }
    else if ((Derived::ColsAtCompileTime != Eigen::Dynamic) && (Derived::ColsAtCompileTime != cols))
    {
      mexPrintf("Column dimension mismatch between Matlab and Eigen objects");
      return false;
    }

    typename Derived::Scalar* data = static_cast<typename Derived::Scalar*>(mxGetData(out));

    for (size_t i=0; i < rows; i++) {
      for (size_t j= 0; j < cols; j++) {
        data[i + j * rows] = in->coeff(i,j);
      }
    }

    return true;
  };

  template<class Derived>
  bool ConvertFromEigenToMatlabMatrix(mxArray** out, Eigen::MatrixBase<Derived>* in) {
    size_t rows = in->rows();
    size_t cols = in->cols();

    if (MxType<typename Derived::Scalar>() == mxUNKNOWN_CLASS) {
      mexPrintf("I don't know how to convert this scalar type to a Matlab matrix");
      return false;
    }

    *out = mxCreateNumericMatrix(rows, cols, MxType<typename Derived::Scalar>(), mxREAL);

    typename Derived::Scalar* data = static_cast<typename Derived::Scalar*>(mxGetData(*out));

    for (size_t i=0; i < rows; i++) {
      for (size_t j=0; j < cols; j++) {
        data[i + j * rows] = in->coeff(i,j);
      }
    }

    return true;
  }

  template<> mxClassID MxType<double>() {return mxDOUBLE_CLASS;};
  template<> mxClassID MxType<int>() {return mxINT32_CLASS;};
%}

%define %eigen_typemaps(CLASS...)

// Argout: const & (Disabled and prevents calling of the non-const typemap)
%typemap(argout, fragment="Eigen_Fragments") const CLASS & ""

// Argout: & (for returning values to in-out arguments)
%typemap(argout, fragment="Eigen_Fragments") CLASS &
{
  // Argout: &
  if (!CopyFromEigenToMatlabMatrix<CLASS >($input, $1))
    SWIG_fail;
}

// In: (nothing: no constness)
%typemap(in, fragment="Eigen_Fragments") CLASS (CLASS temp)
{
  if (!ConvertFromMatlabToEigenMatrix<CLASS >(&temp, $input))
    SWIG_fail;
  $1 = temp;
}
// In: const&
%typemap(in, fragment="Eigen_Fragments") CLASS const& (CLASS temp)
{
  // In: const&
  if (!ConvertFromMatlabToEigenMatrix<CLASS >(&temp, $input))
    SWIG_fail;
  $1 = &temp;
}
// In: MatrixBase const&
%typemap(in, fragment="Eigen_Fragments") Eigen::MatrixBase< CLASS > const& (CLASS temp)
{
  // In: MatrixBase const&
  if (!ConvertFromMatlabToEigenMatrix<CLASS >(&temp, $input))
    SWIG_fail;
  $1 = &temp;
}
// In: & (not yet implemented)
%typemap(in, fragment="Eigen_Fragments") CLASS & (CLASS temp)
{
  // In: non-const&
  if (!ConvertFromMatlabToEigenMatrix<CLASS >(&temp, $input))
    SWIG_fail;

  $1 = &temp;
}
// In: const* (not yet implemented)
%typemap(in, fragment="Eigen_Fragments") CLASS const*
{
  mexPrintf("The input typemap for const pointer is not yet implemented. Please report this problem to the developer.");
  SWIG_fail;
}
// In: * (not yet implemented)
%typemap(in, fragment="Eigen_Fragments") CLASS *
{
  mexPrintf("The input typemap for non-const pointer is not yet implemented. Please report this problem to the developer.");
  SWIG_fail;
}

// Out: (nothing: no constness)
%typemap(out, fragment="Eigen_Fragments") CLASS
{
  if (!ConvertFromEigenToMatlabMatrix<CLASS >(&$result, &$1))
    SWIG_fail;
}
// Out: const
%typemap(out, fragment="Eigen_Fragments") CLASS const
{
  if (!ConvertFromEigenToMatlabMatrix<CLASS >(&$result, &$1))
    SWIG_fail;
}
// Out: const&
%typemap(out, fragment="Eigen_Fragments") CLASS const&
{
  if (!ConvertFromEigenToMatlabMatrix<CLASS >(&$result, $1))
    SWIG_fail;
}
// Out: & (not yet implemented)
%typemap(out, fragment="Eigen_Fragments") CLASS &
{
  mexPrintf("The output typemap for non-const reference is not yet implemented. Please report this problem to the developer.");
  SWIG_fail;
}
// Out: const* (not yet implemented)
%typemap(out, fragment="Eigen_Fragments") CLASS const*
{
  mexPrintf("The output typemap for const pointer is not yet implemented. Please report this problem to the developer.");
  SWIG_fail;
}
// Out: * (not yet implemented)
%typemap(out, fragment="Eigen_Fragments") CLASS *
{
  mexPrintf("The output typemap for non-const pointer is not yet implemented. Please report this problem to the developer.");
  SWIG_fail;
}

%typemap(out, fragment="Eigen_Fragments") std::vector<CLASS >
{
  $result = mxCreateCellMatrix(1, $1.size());
  if (!$result) {
    SWIG_fail;
  }
  for (size_t i=0; i < $1.size(); i++) {
    mxArray* out;
    if (!ConvertFromEigenToMatlabMatrix(&out, &$1[i])) {
      SWIG_fail;
    }
    mxSetCell($result, i, out);
  }
}

%typemap(in, fragment="Eigen_Fragments") std::vector<CLASS > (std::vector<CLASS > temp)
{
  if (!mxIsCell($input)) {
    SWIG_fail;
  }
  temp.resize(mxGetNumberOfElements($input));
  for (size_t i=0; i < mxGetNumberOfElements($input); i++) {
    if (!ConvertFromMatlabToEigenMatrix<CLASS >(&(temp[i]), mxGetCell($input, i))) {
      SWIG_fail;
    }
  }
  $1 = temp;
}

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY)
    CLASS,
    const CLASS &,
    CLASS const &,
    Eigen::MatrixBase< CLASS >,
    const Eigen::MatrixBase< CLASS > &,
    CLASS &
  {
    $1 = mxIsNumeric($input);
  }

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY)
  std::vector<CLASS >
  {
    $1 = mxIsCell($input) && ((mxGetNumberOfElements($input) == 0) || mxIsNumeric(mxGetCell($input, 0)));
  }

%typemap(in, fragment="Eigen_Fragments") const Eigen::Ref<const CLASS >& (CLASS temp)
{
  if (!ConvertFromMatlabToEigenMatrix<CLASS >(&temp, $input))
    SWIG_fail;
  Eigen::Ref<const CLASS > temp_ref(temp);
  $1 = &temp_ref;
}

%enddef
