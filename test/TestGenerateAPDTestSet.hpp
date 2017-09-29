#ifndef TESTGENERATEAPDTESTSET_HPP_
#define TESTGENERATEAPDTESTSET_HPP_

#include <boost/shared_ptr.hpp>
#include <cxxtest/TestSuite.h>

#include "ApdFromParameterSet.hpp"
#include "ColumnDataReader.hpp"
#include "ColumnDataWriter.hpp"

#include "FakePetscSetup.hpp"

/**
 * This test generates a set of Chaste APD90s at the same parameter sets
 *  as projects/ApPredict_GP/test/data/matlabdata.dat
 *
 * and writes them to file in TestGenerateApdTestSet/writeAPD.dat
 * for use in testing the lookup tables and GP emulator later on.
 */
class TestGenerateApdTestSet : public CxxTest::TestSuite
{
private:
    ColumnDataWriter* mpTestWriter;

public:
    void TestOHaraSimulation() throw(Exception)
    {
        OutputFileHandler handler_wipe("ApdCalculatorApp"); // Open and clean folder.
#ifdef CHASTE_CVODE

        // This bit of code is to setup Read / Write to file
        ColumnDataReader reader("projects/ApPredict_GP/test/data", "matlabdata",
                                false);
        std::vector<double> Block_gNa = reader.GetValues("g_Na");
        std::vector<double> Block_gKr = reader.GetValues("g_Kr");
        std::vector<double> Block_gKs = reader.GetValues("g_Ks");
        std::vector<double> Block_gCaL = reader.GetValues("g_CaL");
        std::vector<double> MATLABapd = reader.GetValues("MatAPD");

        mpTestWriter = new ColumnDataWriter("TestGenerateApdTestSet", "writeAPD", false);
        int time_var_id = mpTestWriter->DefineUnlimitedDimension("TestPointIndex",
                                                                 "dimensionless");
        int gNa_var_id = mpTestWriter->DefineVariable("g_Na", "dimensionless");
        int gKr_var_id = mpTestWriter->DefineVariable("g_Kr", "dimensionless");
        int gKs_var_id = mpTestWriter->DefineVariable("g_Ks", "dimensionless");
        int gCaL_var_id = mpTestWriter->DefineVariable("g_CaL", "dimensionless");
        int apd_var_id = mpTestWriter->DefineVariable("APD", "milliseconds");
        int err_var_id = mpTestWriter->DefineVariable("Error_Code", "dimensionless");
        mpTestWriter->EndDefineMode();

        for (unsigned i = 0; i < Block_gNa.size(); i++) // Block_gNa.size()
        {
            std::vector<double> scalings;
            scalings.push_back(Block_gNa[i]);
            scalings.push_back(Block_gKr[i]);
            scalings.push_back(Block_gKs[i]);
            scalings.push_back(Block_gCaL[i]);
            double apd;
            unsigned error_code;
            ApdFromParameterSet(scalings, apd, error_code);

            std::cout << "APD value is:--->" << apd << std::endl;
            mpTestWriter->PutVariable(time_var_id, i + 1);
            mpTestWriter->PutVariable(gNa_var_id, Block_gNa[i]);
            mpTestWriter->PutVariable(gKr_var_id, Block_gKr[i]);
            mpTestWriter->PutVariable(gKs_var_id, Block_gKs[i]);
            mpTestWriter->PutVariable(gCaL_var_id, Block_gCaL[i]);
            mpTestWriter->PutVariable(apd_var_id, apd);
            mpTestWriter->PutVariable(err_var_id, apd);
            mpTestWriter->AdvanceAlongUnlimitedDimension();

            // double delta= std::abs(apd-MATLABapd[i]);
            // TS_ASSERT_LESS_THAN(delta,1);
        }
        delete mpTestWriter;

#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTGENERATEAPDTESTSET_HPP_*/
