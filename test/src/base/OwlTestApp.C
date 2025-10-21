//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "OwlTestApp.h"
#include "OwlApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
OwlTestApp::validParams()
{
  InputParameters params = OwlApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

OwlTestApp::OwlTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  OwlTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

OwlTestApp::~OwlTestApp() {}

void
OwlTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  OwlApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"OwlTestApp"});
    Registry::registerActionsTo(af, {"OwlTestApp"});
  }
}

void
OwlTestApp::registerApps()
{
  registerApp(OwlApp);
  registerApp(OwlTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
OwlTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  OwlTestApp::registerAll(f, af, s);
}
extern "C" void
OwlTestApp__registerApps()
{
  OwlTestApp::registerApps();
}
