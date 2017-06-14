#ifndef TESTAPDFROMPARAMETERSET_HPP_
#define TESTAPDFROMPARAMETERSET_HPP_

#include <cxxtest/TestSuite.h>

#include "ApdFromParameterSet.hpp"

class TestApdFromParameterSet : public CxxTest::TestSuite
{
public:
    // This test should give control APD90
    void TestControlApd() throw(Exception)
    {
#ifdef CHASTE_CVODE
        std::vector<double> scalings;
        scalings.push_back(1.0); // gNa
        scalings.push_back(1.0); // gKr
        scalings.push_back(1.0); // gKs
        scalings.push_back(1.0); // gCaL

        double apd;
        ApdFromParameterSet(scalings, apd);

        TS_ASSERT_DELTA(apd, 268.9157, 1e-4);
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
        ApdFromParameterSet(scalings, apd);

        TS_ASSERT_DELTA(apd, 384.9268, 1e-4);
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
        ApdFromParameterSet(scalings, apd);

        TS_ASSERT_DELTA(apd, 0.0, 1e-6);
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
        ApdFromParameterSet(scalings, apd);

        TS_ASSERT_DELTA(apd, 1000.0, 1e-6);
#else
        std::cout << "Cvode is not enabled, it needs to be to run this project.\n";
#endif
    }
};
#endif /*TESTAPDFROMPARAMETERSET_HPP_*/
