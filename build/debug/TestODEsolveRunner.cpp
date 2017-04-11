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
#include "projects/ApPredict_GP/test/TestODEsolve.hpp"

static TestSingleCellTutorial suite_TestSingleCellTutorial;

static CxxTest::List Tests_TestSingleCellTutorial = { 0, 0 };
CxxTest::StaticSuiteDescription suiteDescription_TestSingleCellTutorial( "projects/ApPredict_GP/test/TestODEsolve.hpp", 28, "TestSingleCellTutorial", suite_TestSingleCellTutorial, Tests_TestSingleCellTutorial );

static class TestDescription_TestSingleCellTutorial_TestOHaraSimulation : public CxxTest::RealTestDescription {
public:
 TestDescription_TestSingleCellTutorial_TestOHaraSimulation() : CxxTest::RealTestDescription( Tests_TestSingleCellTutorial, suiteDescription_TestSingleCellTutorial, 31, "TestOHaraSimulation" ) {}
 void runTest() { suite_TestSingleCellTutorial.TestOHaraSimulation(); }
} testDescription_TestSingleCellTutorial_TestOHaraSimulation;

#include <cxxtest/Root.cpp>
