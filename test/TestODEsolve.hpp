#ifndef TESTODESOLVE_HPP_
#define TESTODESOLVE_HPP_

#include <cxxtest/TestSuite.h>
#include "ColumnDataReader.hpp"

#include "ApdFromParameterSet.hpp"

class TestODEsolve : public CxxTest::TestSuite
{
public:
    void TestOHaraSimulation() throw(Exception)
    {
#ifdef CHASTE_CVODE

        ColumnDataReader reader("projects/ApPredict_GP/test/data", "matlabdata", false);
        std::vector<double> Block_gNa = reader.GetValues("g_Na");
        std::vector<double> Block_gKr = reader.GetValues("g_Kr");
        std::vector<double> Block_gKs = reader.GetValues("g_Ks");
        std::vector<double> Block_gCaL = reader.GetValues("g_CaL");
        std::vector<double> MATLABapd = reader.GetValues("MatAPD");

        // This bit of code is a sanity checker
        std::cout << "Block value gNa:--->" << Block_gNa[1] << std::endl;
        std::cout << "Block value gKr:--->" << Block_gKr[1] << std::endl;
        std::cout << "Block value gKs:--->" << Block_gKs[1] << std::endl;
        std::cout << "Block value gCal:--->" << Block_gCaL[1] << std::endl;

        std::vector<double> scalings;
        scalings.push_back(Block_gNa[1]);
        scalings.push_back(Block_gKr[1]);
        scalings.push_back(Block_gKs[1]);
        scalings.push_back(Block_gCaL[1]);
        double apd;
        ApdFromParameterSet(scalings, apd);

        std::cout << "APD value is:--->" << apd << std::endl;

#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTODESOLVE_HPP_*/
