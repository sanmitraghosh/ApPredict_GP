#ifndef TESTAPDFROMPARAMETERSET_HPP_
#define TESTAPDFROMPARAMETERSET_HPP_

#include <cxxtest/TestSuite.h>

#include "OutputFileHandler.hpp"

#include "ApdFromParameterSet.hpp"

class TestApdFromParameterSet : public CxxTest::TestSuite
{
public:
    // This test should give control APD90
    void TestControlApd() throw(Exception)
    {
        OutputFileHandler handler("ApdCalculatorApp"); // Open and clean folder.

#ifdef CHASTE_CVODE
        std::vector<double> scalings;
        scalings.push_back(1.0); // gNa
        scalings.push_back(1.0); // gKr
        scalings.push_back(1.0); // gKs
        scalings.push_back(1.0); // gCaL

        double apd;
        unsigned error_code;
        ApdFromParameterSet(scalings, apd, error_code);

        TS_ASSERT_DELTA(apd, 268.9191, 1e-3);
        TS_ASSERT_EQUALS(error_code, 0u);
    }

    // This time we should load up saved state variables and voltage threshold
    void TestControlApdAgain() throw(Exception)
    {
        std::vector<double> scalings;
        scalings.push_back(1.0); // gNa
        scalings.push_back(1.0); // gKr
        scalings.push_back(1.0); // gKs
        scalings.push_back(1.0); // gCaL

        double apd;
        unsigned error_code;
        ApdFromParameterSet(scalings, apd, error_code);

        TS_ASSERT_DELTA(apd, 268.9274, 2e-3); // It moves a bit as it runs steady state again...
        TS_ASSERT_EQUALS(error_code, 0u);
    }

    // This test should give prolonged 50% IKr block
    void TestDrugBlockApd() throw(Exception)
    {

        std::vector<double> scalings;
        scalings.push_back(1.0); // gNa
        scalings.push_back(0.5); // gKr
        scalings.push_back(1.0); // gKs
        scalings.push_back(1.0); // gCaL

        double apd;
        unsigned error_code;
        ApdFromParameterSet(scalings, apd, error_code);

        TS_ASSERT_DELTA(apd, 384.9271, 1e-3);
        TS_ASSERT_EQUALS(error_code, 0u);
    }

    // This test should give No Depolarization error code.
    void TestNoAp1() throw(Exception)
    {
        std::vector<double> scalings;
        scalings.push_back(0.0); // gNa
        scalings.push_back(1.0); // gKr
        scalings.push_back(1.0); // gKs
        scalings.push_back(1.0); // gCaL

        double apd;
        unsigned error_code;
        ApdFromParameterSet(scalings, apd, error_code);

        TS_ASSERT_DELTA(apd, 0.0, 1e-6);
        TS_ASSERT_EQUALS(error_code, 1u);
    }

    // This test should give No Repolarization error code.
    void TestNoAp2() throw(Exception)
    {
        std::vector<double> scalings;
        scalings.push_back(1.0); // gNa
        scalings.push_back(0.0); // gKr
        scalings.push_back(1.0); // gKs
        scalings.push_back(1.0); // gCaL

        double apd;
        unsigned error_code;
        ApdFromParameterSet(scalings, apd, error_code);

        TS_ASSERT_DELTA(apd, 1000.0, 1e-6);
        TS_ASSERT_EQUALS(error_code, 2u);
#else
        std::cout << "Cvode is not enabled, it needs to be to run this project.\n";
#endif
    }
};
#endif /*TESTAPDFROMPARAMETERSET_HPP_*/
