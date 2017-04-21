#ifndef TESTGENERATEAPDTESTSET_HPP_
#define TESTGENERATEAPDTESTSET_HPP_

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
#include "FakePetscSetup.hpp"
#include <iostream>
#include <fstream>
#include <numeric>
#include <cmath>
#include <boost/lexical_cast.hpp>
class TestgenerateAPDTestSet : public CxxTest::TestSuite
{
private:
    ColumnDataWriter* mpTestWriter;
    //ColumnDataReader* mpTestReader;
public:
    void TestOHaraSimulation() throw(Exception)
    {
#ifdef CHASTE_CVODE

        //Setup Model
        boost::shared_ptr<RegularStimulus> p_stimulus;
        boost::shared_ptr<EulerIvpOdeSolver> p_solver;
        boost::shared_ptr<AbstractCvodeCell> p_model(new Cellohara_rudy_2011_endoFromCellMLCvode(p_solver, p_stimulus));
        boost::shared_ptr<RegularStimulus> p_regular_stim = p_model->UseCellMLDefaultStimulus();

        std::cout<< "Stim start value is:--->"<<p_regular_stim->GetStartTime()<<std::endl;
        std::cout<< "Stim magnitude value is:--->"<<p_regular_stim->GetMagnitude()<<std::endl;
        p_regular_stim->SetPeriod(1000);
        p_model->SetTolerances(1e-6,1e-8);
        double max_timestep = 0.5;
        p_model->SetMaxTimestep(max_timestep);
        p_regular_stim->SetStartTime(10);
        double sampling_timestep = 0.1;//max_timestep;
        double start_time = 0.0;
        double end_time = 1000.0;

        //Get IVPs
        SteadyStateRunner steady_runner(p_model);
        steady_runner.SetMaxNumPaces(1000u);
        steady_runner.RunToSteadyState();
        OdeSolution solution = p_model->Compute(start_time, end_time, sampling_timestep);
        std::vector<double> StateVars=p_model->GetStdVecStateVariables();

        //Use Gary's Runner later for Error messages
        SingleActionPotentialPrediction ap_runner(p_model);
        ap_runner.SuppressOutput();
        ap_runner.SetMaxNumPaces(1000u);
        ap_runner.SetLackOfOneToOneCorrespondenceIsError();
        ap_runner.SetVoltageThresholdForRecordingAsActionPotential(-50);
        //Model Setup Finished

        // Get model parameters
        std::vector<double> param;
        param.push_back(p_model->GetParameter("membrane_fast_sodium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_L_type_calcium_current_conductance"));



        // This bit of code is to setup Read Write to fle
        ColumnDataReader reader("projects/ApPredict_GP/test/data", "testunlimited",false);
        std::vector<double> Block_gNa = reader.GetValues("g_Na");
        std::vector<double> Block_gKr = reader.GetValues("g_Kr");
        std::vector<double> Block_gKs = reader.GetValues("g_Ks");
        std::vector<double> Block_gCal = reader.GetValues("g_CaL");
        std::vector<double> MATLABapd = reader.GetValues("MatAPD");

         mpTestWriter = new ColumnDataWriter("TestColumnDataReaderWriter", "writeAPD", false);
         int time_var_id = 0;
         int apd_var_id = 0;

         TS_ASSERT_THROWS_NOTHING(time_var_id = mpTestWriter->DefineUnlimitedDimension("Time","msecs"));
         TS_ASSERT_THROWS_NOTHING(apd_var_id = mpTestWriter->DefineVariable("APD","milliseconds"));
         TS_ASSERT_THROWS_NOTHING(mpTestWriter->EndDefineMode());


        double apd;
        for(unsigned i=35;i<40;i++)//Block_gNa.size()
        {
                p_model->SetParameter("membrane_fast_sodium_current_conductance", Block_gNa[i]*param[0]);
                p_model->SetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance", Block_gKr[i]*param[1]);
                p_model->SetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance", Block_gKs[i]*param[2]);
                p_model->SetParameter("membrane_L_type_calcium_current_conductance", Block_gCal[i]*param[3]);

                p_model->SetStateVariables(StateVars);
                ap_runner.RunSteadyPacingExperiment();
                if (ap_runner.DidErrorOccur())
                {
                    std::string error_message = ap_runner.GetErrorMessage();
                    std::cout << "Lookup table generator reports that " << error_message
                              << "\n"
                              << std::flush;
                    // We could use different numerical codes for different errors here if we wanted to.
                    if (error_message == "NoActionPotential_2" || error_message == "NoActionPotential_3")
                    {
                        // For an APD calculation failure on repolarisation put in the stimulus period.
                        apd = 1000.0;
                        mpTestWriter->PutVariable(time_var_id, i);
                        mpTestWriter->PutVariable(apd_var_id, apd);
                        mpTestWriter->AdvanceAlongUnlimitedDimension();


                    }
                    else
                    {
                        // For everything else (failure to depolarize "NoActionPotential_1")
                        // just put in zero for now.
                        mpTestWriter->PutVariable(time_var_id, i);
                        mpTestWriter->PutVariable(apd_var_id, apd);
                        mpTestWriter->AdvanceAlongUnlimitedDimension();
                        apd=0.0;
                    }
                    continue;
                }

                apd = ap_runner.GetApd90();
                std::cout<< "APD value is:--->"<<apd<<std::endl;
                mpTestWriter->PutVariable(time_var_id, i);
                mpTestWriter->PutVariable(apd_var_id, apd);
                mpTestWriter->AdvanceAlongUnlimitedDimension();


                //double delta= std::abs(apd-MATLABapd[i]);
                //TS_ASSERT_LESS_THAN(delta,1);


        }
        delete mpTestWriter;




        /*
        mpTestReader = new ColumnDataReader("TestColumnDataReaderWriter", "writeAPD");

        std::vector<double> values_apd = mpTestReader->GetValues("APD");
        for(unsigned i=0;i<5;i++)
                {
            TS_ASSERT_EQUALS(values_apd[i],50u)
                }
                */


#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTGENERATEAPDTESTSET_HPP_*/

