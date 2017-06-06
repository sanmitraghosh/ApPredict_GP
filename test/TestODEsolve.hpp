#ifndef TESTODESOLVE_HPP_
#define TESTODESOLVE_HPP_

#include <cxxtest/TestSuite.h>
#include <boost/shared_ptr.hpp>
#include <boost/assign/list_of.hpp>
#include <ColumnDataReader.hpp>
#include <ColumnDataWriter.hpp>
#include "CellProperties.hpp"
#include "SteadyStateRunner.hpp"
#include "AbstractCvodeCell.hpp"
#include "AbstractCardiacCell.hpp"
#include "RegularStimulus.hpp"
#include "ZeroStimulus.hpp"
#include "EulerIvpOdeSolver.hpp"
#include "Shannon2004Cvode.hpp"
#include "ohara_rudy_2011_endo.hpp"
#include "ohara_rudy_2011_endoOpt.hpp"
#include "ohara_rudy_2011_endoCvode.hpp"
#include "ohara_rudy_2011_endoCvodeOpt.hpp"
#include "SingleActionPotentialPrediction.hpp"
#include "LookupTableGenerator.hpp"
#include "NumericFileComparison.hpp"
#include "FakePetscSetup.hpp"
#include <iostream>
#include <fstream>
#include <numeric>
#include <cmath>
#include <boost/lexical_cast.hpp>
class TestODEsolve : public CxxTest::TestSuite
{
private:
    bool CalledCollectively;
    bool SuppressOutput;
    bool expected_fail_result;

public:
    void TestOHaraSimulation() throw(Exception)
    {
#ifdef CHASTE_CVODE
        boost::shared_ptr<RegularStimulus> p_stimulus;
        boost::shared_ptr<EulerIvpOdeSolver> p_solver;
        boost::shared_ptr<AbstractCvodeCell> p_model(new Cellohara_rudy_2011_endoFromCellMLCvode(p_solver, p_stimulus));
        boost::shared_ptr<RegularStimulus> p_regular_stim = p_model->UseCellMLDefaultStimulus();

        //unsigned TESTFLAG=1;
        std::cout<< "Stim start value is:--->"<<p_regular_stim->GetStartTime()<<std::endl;
        std::cout<< "Stim magnitude value is:--->"<<p_regular_stim->GetMagnitude()<<std::endl;
        p_regular_stim->SetPeriod(1000);


        ColumnDataReader reader("projects/ApPredict_GP/test/data", "matlabdata",false);
        std::vector<double> Block_gNa = reader.GetValues("g_Na");
        std::vector<double> Block_gKr = reader.GetValues("g_Kr");
        std::vector<double> Block_gKs = reader.GetValues("g_Ks");
        std::vector<double> Block_gCal = reader.GetValues("g_CaL");
        std::vector<double> MATLABapd = reader.GetValues("MatAPD");

        /* Run to Limit Cycle */
        SteadyStateRunner steady_runner(p_model);
        steady_runner.SetMaxNumPaces(100u);
        bool result;
        p_model->SetTolerances(1e-6,1e-8);
        double max_timestep = 0.5;
        p_model->SetMaxTimestep(max_timestep);
        p_regular_stim->SetStartTime(10);
        double sampling_timestep = 0.1;//max_timestep;
        double start_time = 0.0;
        double end_time = 1000.0;
        result = steady_runner.RunToSteadyState();
        TS_ASSERT_EQUALS(result,false);
        OdeSolution solution = p_model->Compute(start_time, end_time, sampling_timestep);
        std::vector<double> StateVars = p_model->GetStdVecStateVariables();
        std::cout<< "State Vars:--->"<<StateVars.size()<<std::endl;



        p_model->SetStateVariables(StateVars);
        SingleActionPotentialPrediction ap_runner(p_model);
        ap_runner.SuppressOutput();
        ap_runner.SetLackOfOneToOneCorrespondenceIsError();
        double threshold_voltage;
        ap_runner.SetMaxNumPaces(100u);
        if (p_model->HasParameter("membrane_fast_sodium_current_conductance"))
        {
            const double original_na_conductance = p_model->GetParameter("membrane_fast_sodium_current_conductance");
            p_model->SetParameter("membrane_fast_sodium_current_conductance", 0u);

            solution = ap_runner.RunSteadyPacingExperiment();

            // Put it back where it was! The calling method will reset state variables.
            p_model->SetParameter("membrane_fast_sodium_current_conductance",
                                 original_na_conductance);

            std::vector<double> voltages = solution.GetAnyVariable("membrane_voltage");
            double max_voltage = *(std::max_element(voltages.begin(), voltages.end()));
            double min_voltage = *(std::min_element(voltages.begin(), voltages.end()));

            // Go 10% over the depolarization jump at gNa=0 as a threshold for 'this really is an AP'.
            threshold_voltage= min_voltage + 1.1 * (max_voltage - min_voltage);
            std::cout<< "Threshold value is:--->"<<threshold_voltage<<std::endl;
        }
        else
        {
            threshold_voltage= -50.0; // mV
        }




        std::vector<double> param;
        param.push_back(p_model->GetParameter("membrane_fast_sodium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_L_type_calcium_current_conductance"));



        // This bit of code is a sanity checker
        p_model->SetParameter("membrane_fast_sodium_current_conductance", Block_gNa[1]*param[0]);
        p_model->SetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance", Block_gKr[1]*param[1]);
        p_model->SetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance", Block_gKs[1]*param[2]);
        p_model->SetParameter("membrane_L_type_calcium_current_conductance", Block_gCal[1]*param[3]);
        std::cout<< "Block value gNa:--->"<<Block_gNa[1]<<std::endl;
        std::cout<< "Block value gKr:--->"<<Block_gKr[1]<<std::endl;
        std::cout<< "Block value gKs:--->"<<Block_gKs[1]<<std::endl;
        std::cout<< "Block value gCal:--->"<<Block_gCal[1]<<std::endl;


        p_model->SetStateVariables(StateVars);
        ap_runner.SetVoltageThresholdForRecordingAsActionPotential(threshold_voltage);
        solution = ap_runner.RunSteadyPacingExperiment();
        solution.WriteToFile("TestSingleAPD","ohara_rudy_2011_endoCvode","ms");

        unsigned voltage_index = p_model->GetSystemInformation()->GetStateVariableIndex("membrane_voltage");
        std::vector<double> voltages = solution.GetVariableAtIndex(voltage_index);
        CellProperties cell_props(voltages, solution.rGetTimes(),-50);
        double apd = cell_props.GetLastActionPotentialDuration(90);
        std::cout<< "APD value is:--->"<<apd<<std::endl;


        CalledCollectively = true;
        SuppressOutput = true;
        expected_fail_result = !PetscTools::AmMaster();

        std::string base_file = "./projects/ApPredict_GP/test/data/dummy.dat";
        std::string noised_file = "./projects/ApPredict_GP/test/data/dummyplus0.1.dat";


        NumericFileComparison different_data(base_file, noised_file, CalledCollectively, SuppressOutput);
        TS_ASSERT(different_data.CompareFiles(2e-2, 0, 2e-2, false));
        /*
        NumericFileComparison different_data(base_file, noised_file, CalledCollectively, SuppressOutput);
        TS_ASSERT(different_data.CompareFiles(1e-4));

        TS_ASSERT_EQUALS(different_data.CompareFiles(1e-9, 0, 1e-9, false), expected_fail_result);
        */
#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTODESOLVE_HPP_*/

