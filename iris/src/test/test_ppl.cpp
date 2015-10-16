#include <stdio.h>
#include "ppl.hh"
#include "iris/iris.h"

// Note: this test is no longer in use (and never really worked anyway). I'm just keeping it around in case I ever want to try again with PPL. 

using namespace Parma_Polyhedra_Library;
using namespace Eigen;

struct Floating_Real_Open_Interval_Info_Policy {
  const_bool_nodef(store_special, false);
  const_bool_nodef(store_open, true);
  const_bool_nodef(cache_empty, true);
  const_bool_nodef(cache_singleton, true);
  const_bool_nodef(cache_normalized, false);
  const_int_nodef(next_bit, 0);
  const_bool_nodef(may_be_empty, true);
  const_bool_nodef(may_contain_infinity, false);
  const_bool_nodef(check_empty_result, false);
  const_bool_nodef(check_inexact, false);
};

typedef Interval_Info_Bitset<unsigned int,
                             Floating_Real_Open_Interval_Info_Policy> Floating_Real_Open_Interval_Info;

//! The type of an interval with floating point boundaries.
typedef Interval<double,
                 Floating_Real_Open_Interval_Info> FP_Interval;

//! The type of an interval linear form.
typedef Linear_Form<FP_Interval> FP_Linear_Form;

//! The type of an interval abstract store.
typedef Box<FP_Interval> FP_Interval_Abstract_Store;

void getGenerators(const Polyhedron* self) {
  const int dim = self->getDimension();
  NNC_Polyhedron ppl_polyhedron(dim);
  std::vector<Variable> vars;
  for (int i=0; i < dim; i++) {
    Variable v(i);
    vars.push_back(v);
  }
  for (int i=0; i < self->getNumberOfConstraints(); i++) {
    FP_Linear_Form expr;
    for (int j=0; j < dim; j++) {
      expr += FP_Linear_Form(self->getA()(i,j) * vars[j]);
    }
    expr.print();
    printf("\n");
    FP_Linear_Form right(self->getB()(i) + 0.0 * vars[0]);
    right.print();
    printf("\n");
    ppl_polyhedron.refine_with_linear_form_inequality(expr, right);
    // ppl_polyhedron.add_constraint(expr <= Linear_Form<double>(self->getB()(i)));
  }

  auto generators = ppl_polyhedron.generators();
  generators.print();
  std::cout << std::endl;
  for (auto gen = generators.begin(); gen != generators.end(); ++gen) {
    gen->print();
    // for (int i=0; i < dim; i++) {
    //   printf("%f", static_cast<const int>(gen->coefficient(vars[i])));
    // }
    printf("\n");
    // printf(" %d\n", static_cast<const int> gen->divisor());
  }

  ppl_polyhedron.constraints().print();
}


int main(int argc, char **argv) {

  MatrixXd A(4,2);
  A << 1.1, 0.9,
       0, 1,
       -1, 0,
       0, -1;
  VectorXd b(4);
  b << 0.5, 0.5, 0.5, 0.5;
  Polyhedron poly(A, b);
  getGenerators(&poly);

  return 0;
}