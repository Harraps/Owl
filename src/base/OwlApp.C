#include "OwlApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
OwlApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

OwlApp::OwlApp(const InputParameters & parameters) : MooseApp(parameters)
{
  OwlApp::registerAll(_factory, _action_factory, _syntax);
}

OwlApp::~OwlApp() {}

void
OwlApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<OwlApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"OwlApp"});
  Registry::registerActionsTo(af, {"OwlApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
OwlApp::registerApps()
{
  registerApp(OwlApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
OwlApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  OwlApp::registerAll(f, af, s);
}
extern "C" void
OwlApp__registerApps()
{
  OwlApp::registerApps();
}
