#ifndef TESTAPDPROFILE_HPP_
#define TESTAPDPROFILE_HPP_

#include <boost/shared_ptr.hpp>
#include <cxxtest/TestSuite.h>

#include "ApdFromParameterSet.hpp"
#include "ColumnDataWriter.hpp"
#include "FileFinder.hpp"

#include "FakePetscSetup.hpp"

/**
 * This test generates a set of Chaste APD90s along a slice of parameter space to check sanity!
 *
 * It mainly uses the class ApdFromParameterSet.
 */
class TestApdProfile : public CxxTest::TestSuite
{
private:
    ColumnDataWriter* mpTestWriter;

public:
    void TestOHaraSimulation() throw(Exception)
    {
#ifdef CHASTE_CVODE

        mpTestWriter = new ColumnDataWriter("TestApdProfile", "APDs", false);
        int time_var_id = mpTestWriter->DefineUnlimitedDimension("TestPointIndex",
                                                                 "dimensionless");
        int gNa_var_id = mpTestWriter->DefineVariable("g_Na", "dimensionless");
        int gKr_var_id = mpTestWriter->DefineVariable("g_Kr", "dimensionless");
        int apd_var_id = mpTestWriter->DefineVariable("APD", "milliseconds");
        mpTestWriter->EndDefineMode();

        double block_gKr = 0.5; // Take a 1D slice of parameter space.

        unsigned resolution = 100u; // subdivisions of gNa (one more evaluation for each end)
        std::vector<double> block_gNa(resolution);
        for (unsigned i = 0; i <= resolution; i++)
        {
            block_gNa[i] = double(i) / double(resolution);
        }

        // Make a FileFinder to collect the APDs and see what is going on.
        FileFinder* p_file_finder = new FileFinder("TestApdProfile", RelativeTo::ChasteTestOutput);

        for (unsigned i = 0; i < block_gNa.size(); i++)
        {
            std::vector<double> scalings;
            scalings.push_back(block_gNa[i]);
            scalings.push_back(block_gKr);
            double apd;
            ApdFromParameterSet(scalings, apd, p_file_finder);

            std::cout << i << "\t APD = " << apd << "ms" << std::endl;
            mpTestWriter->PutVariable(time_var_id, i + 1);
            mpTestWriter->PutVariable(gNa_var_id, block_gNa[i]);
            mpTestWriter->PutVariable(gKr_var_id, block_gKr);
            mpTestWriter->PutVariable(apd_var_id, apd);
            mpTestWriter->AdvanceAlongUnlimitedDimension();
        }
        delete mpTestWriter;
        delete p_file_finder;
#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTAPDPROFILE_HPP_*/
