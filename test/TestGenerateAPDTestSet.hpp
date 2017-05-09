#ifndef TESTGENERATEAPDTESTSET_HPP_
#define TESTGENERATEAPDTESTSET_HPP_

#include <boost/shared_ptr.hpp>
#include <cxxtest/TestSuite.h>

#include <ColumnDataReader.hpp>
#include <ColumnDataWriter.hpp>
#include "AbstractCvodeCell.hpp"
#include "CellProperties.hpp"
#include "EulerIvpOdeSolver.hpp"
#include "LookupTableGenerator.hpp"
#include "RegularStimulus.hpp"
#include "SingleActionPotentialPrediction.hpp"
#include "ohara_rudy_2011_endoCvode.hpp"

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
#ifdef CHASTE_CVODE

        // Setup Model
        boost::shared_ptr<RegularStimulus> p_stimulus;
        boost::shared_ptr<EulerIvpOdeSolver> p_solver;
        boost::shared_ptr<AbstractCvodeCell> p_model(
            new Cellohara_rudy_2011_endoFromCellMLCvode(p_solver, p_stimulus));
        boost::shared_ptr<RegularStimulus> p_regular_stim = p_model->UseCellMLDefaultStimulus();

        std::cout << "Stim start value is:--->" << p_regular_stim->GetStartTime()
                  << std::endl;
        std::cout << "Stim magnitude value is:--->"
                  << p_regular_stim->GetMagnitude() << std::endl;
        p_regular_stim->SetPeriod(1000);
        p_model->SetTolerances(1e-6, 1e-8);
        double max_timestep = 0.5;
        p_model->SetMaxTimestep(max_timestep);
        p_regular_stim->SetStartTime(10);
        double sampling_timestep = 0.1; // max_timestep;
        double start_time = 0.0;
        double end_time = 1000.0;
        unsigned Init_Pace = 100u;
        // Get IVPs
        SteadyStateRunner steady_runner(p_model);
        steady_runner.SetMaxNumPaces(Init_Pace);
        steady_runner.RunToSteadyState();
        OdeSolution solution = p_model->Compute(start_time, end_time, sampling_timestep);
        std::vector<double> StateVars = p_model->GetStdVecStateVariables();

        // Use Gary's Runner later for Error messages
        SingleActionPotentialPrediction ap_runner(p_model);
        ap_runner.SuppressOutput();
        ap_runner.SetMaxNumPaces(Init_Pace);
        ap_runner.SetLackOfOneToOneCorrespondenceIsError();
        double threshold_voltage = LookupTableGenerator<4>::DetectVoltageThresholdForActionPotential(p_model);
        ap_runner.SetVoltageThresholdForRecordingAsActionPotential(threshold_voltage);
        // Model Setup Finished

        // Get model parameters
        std::vector<double> param;
        param.push_back(
            p_model->GetParameter("membrane_fast_sodium_current_conductance"));
        param.push_back(p_model->GetParameter(
            "membrane_rapid_delayed_rectifier_potassium_current_conductance"));
        param.push_back(p_model->GetParameter(
            "membrane_slow_delayed_rectifier_potassium_current_conductance"));
        param.push_back(
            p_model->GetParameter("membrane_L_type_calcium_current_conductance"));

        // This bit of code is to setup Read / Write to file
        ColumnDataReader reader("projects/ApPredict_GP/test/data", "matlabdata",
                                false);
        std::vector<double> Block_gNa = reader.GetValues("g_Na");
        std::vector<double> Block_gKr = reader.GetValues("g_Kr");
        std::vector<double> Block_gKs = reader.GetValues("g_Ks");
        std::vector<double> Block_gCal = reader.GetValues("g_CaL");
        std::vector<double> MATLABapd = reader.GetValues("MatAPD");

        mpTestWriter = new ColumnDataWriter("TestGenerateApdTestSet", "writeAPD", false);
        int time_var_id = mpTestWriter->DefineUnlimitedDimension("TestPointIndex",
                                                                 "dimensionless");
        int gNa_var_id = mpTestWriter->DefineVariable("g_Na", "dimensionless");
        int gKr_var_id = mpTestWriter->DefineVariable("g_Kr", "dimensionless");
        int gKs_var_id = mpTestWriter->DefineVariable("g_Ks", "dimensionless");
        int gCaL_var_id = mpTestWriter->DefineVariable("g_CaL", "dimensionless");
        int apd_var_id = mpTestWriter->DefineVariable("APD", "milliseconds");
        mpTestWriter->EndDefineMode();

        double apd;
        for (unsigned i = 0; i < Block_gNa.size(); i++) // Block_gNa.size()
        {
            p_model->SetParameter("membrane_fast_sodium_current_conductance",
                                  Block_gNa[i] * param[0]);
            p_model->SetParameter(
                "membrane_rapid_delayed_rectifier_potassium_current_conductance",
                Block_gKr[i] * param[1]);
            p_model->SetParameter(
                "membrane_slow_delayed_rectifier_potassium_current_conductance",
                Block_gKs[i] * param[2]);
            p_model->SetParameter("membrane_L_type_calcium_current_conductance",
                                  Block_gCal[i] * param[3]);

            p_model->SetStateVariables(StateVars);
            ap_runner.RunSteadyPacingExperiment();
            if (ap_runner.DidErrorOccur())
            {
                std::string error_message = ap_runner.GetErrorMessage();
                std::cout << "Lookup table generator reports that " << error_message
                          << "\n"
                          << std::flush;
                // We could use different numerical codes for different errors here if
                // we wanted to.
                if (error_message == "NoActionPotential_2" || error_message == "NoActionPotential_3")
                {
                    // For an APD calculation failure on repolarisation put in the
                    // stimulus period.
                    apd = 1000.0;
                }
                else
                {
                    // For everything else (failure to depolarize "NoActionPotential_1")
                    // just put in zero for now.
                    apd = 0.0;
                }
            }
            else
            {
                apd = ap_runner.GetApd90();
            }

            std::cout << "APD value is:--->" << apd << std::endl;
            mpTestWriter->PutVariable(time_var_id, i + 1);
            mpTestWriter->PutVariable(gNa_var_id, Block_gNa[i]);
            mpTestWriter->PutVariable(gKr_var_id, Block_gKr[i]);
            mpTestWriter->PutVariable(gKs_var_id, Block_gKs[i]);
            mpTestWriter->PutVariable(gCaL_var_id, Block_gCal[i]);
            mpTestWriter->PutVariable(apd_var_id, apd);
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
