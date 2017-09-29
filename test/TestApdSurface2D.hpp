#ifndef TESTAPDSURFACE2D_HPP_
#define TESTAPDSURFACE2D_HPP_

#include <boost/shared_ptr.hpp>
#include <cxxtest/TestSuite.h>

#include "ApdFromParameterSet.hpp"
#include "ColumnDataWriter.hpp"
#include "FileFinder.hpp"
#include "RandomNumberGenerator.hpp"

#include "FakePetscSetup.hpp"

/**
 * This test generates a set of Chaste APD90s along a slice of parameter space to check sanity!
 *
 * It mainly uses the class ApdFromParameterSet.
 */
class TestApdSurface2D : public CxxTest::TestSuite
{
private:
    ColumnDataWriter* mpTestWriter;

public:
    void TestOHaraSimulation() throw(Exception)
    {
#ifdef CHASTE_CVODE

        std::string output_folder = "TestApdSurface2D";

        OutputFileHandler handler_wipe("ApdCalculatorApp"); // Open and clean folder.
        OutputFileHandler handler(output_folder);

        mpTestWriter = new ColumnDataWriter(output_folder, "APDs", false);
        int time_var_id = mpTestWriter->DefineUnlimitedDimension("TestPointIndex",
                                                                 "dimensionless");
        int gNa_var_id = mpTestWriter->DefineVariable("g_Na", "dimensionless");
        int gKr_var_id = mpTestWriter->DefineVariable("g_Kr", "dimensionless");
        int apd_var_id = mpTestWriter->DefineVariable("APD", "milliseconds");
        int err_var_id = mpTestWriter->DefineVariable("ErrorCode", "dimensionless");
        mpTestWriter->EndDefineMode();

        unsigned num_samples = 1000u;
        std::vector<double> block_gKr(num_samples);
        std::vector<double> block_gNa(num_samples);

        for (unsigned i = 0; i < num_samples; i++)
        {
            block_gKr[i] = RandomNumberGenerator::Instance()->ranf();
            block_gNa[i] = RandomNumberGenerator::Instance()->ranf();
        }

        // Make a FileFinder to collect the APDs and see what is going on.
        FileFinder* p_file_finder = new FileFinder(output_folder, RelativeTo::ChasteTestOutput);

        for (unsigned i = 0; i < num_samples; i++)
        {
            std::vector<double> scalings;
            scalings.push_back(block_gNa[i]);
            scalings.push_back(block_gKr[i]);
            double apd;
            unsigned error_code;
            ApdFromParameterSet(scalings, apd, error_code, p_file_finder);

            std::cout << i << "\tGNa = " << block_gNa[i] << "\tGKr = " << block_gKr[i] << "\tAPD = " << apd << "ms\tError Code = " << error_code << std::endl;
            mpTestWriter->PutVariable(time_var_id, i + 1);
            mpTestWriter->PutVariable(gNa_var_id, block_gNa[i]);
            mpTestWriter->PutVariable(gKr_var_id, block_gKr[i]);
            mpTestWriter->PutVariable(apd_var_id, apd);
            mpTestWriter->PutVariable(err_var_id, error_code);
            mpTestWriter->AdvanceAlongUnlimitedDimension();
        }
        delete mpTestWriter;
        delete p_file_finder;
#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTAPDSURFACE2D_HPP_*/
