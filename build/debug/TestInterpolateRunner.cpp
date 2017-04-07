/* Generated file, do not edit */

#ifndef CXXTEST_RUNNING
#define CXXTEST_RUNNING
#endif

#define _CXXTEST_HAVE_STD
#define _CXXTEST_HAVE_EH
#include <cxxtest/TestListener.h>
#include <cxxtest/TestTracker.h>
#include <cxxtest/TestRunner.h>
#include <cxxtest/RealDescriptions.h>
#include <cxxtest/ErrorPrinter.h>

#include "CommandLineArguments.hpp"
int main( int argc, char *argv[] ) {
 CommandLineArguments::Instance()->p_argc = &argc;
 CommandLineArguments::Instance()->p_argv = &argv;
 return CxxTest::ErrorPrinter().run();
}
#include "projects/ApPredict_GP/test/TestInterpolate.hpp"

static TestInterpolateVsGP suite_TestInterpolateVsGP;

static CxxTest::List Tests_TestInterpolateVsGP = { 0, 0 };
CxxTest::StaticSuiteDescription suiteDescription_TestInterpolateVsGP( "projects/ApPredict_GP/test/TestInterpolate.hpp", 29, "TestInterpolateVsGP", suite_TestInterpolateVsGP, Tests_TestInterpolateVsGP );

static class TestDescription_TestInterpolateVsGP_TestInterpolate : public CxxTest::RealTestDescription {
public:
 TestDescription_TestInterpolateVsGP_TestInterpolate() : CxxTest::RealTestDescription( Tests_TestInterpolateVsGP, suiteDescription_TestInterpolateVsGP, 32, "TestInterpolate" ) {}
 void runTest() { suite_TestInterpolateVsGP.TestInterpolate(); }
} testDescription_TestInterpolateVsGP_TestInterpolate;

#include <cxxtest/Root.cpp>
