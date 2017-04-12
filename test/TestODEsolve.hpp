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

#include "FakePetscSetup.hpp"
#include <iostream>
#include <fstream>
#include <numeric>
#include <cmath>
#include <boost/lexical_cast.hpp>
class TestSingleCellTutorial : public CxxTest::TestSuite
{
public:
    void TestOHaraSimulation() throw(Exception)
    {
#ifdef CHASTE_CVODE
        boost::shared_ptr<RegularStimulus> p_stimulus;
        boost::shared_ptr<EulerIvpOdeSolver> p_solver;
        boost::shared_ptr<AbstractCvodeCell> p_model(new Cellohara_rudy_2011_endoFromCellMLCvode(p_solver, p_stimulus));
        boost::shared_ptr<RegularStimulus> p_regular_stim = p_model->UseCellMLDefaultStimulus();

        unsigned TESTFLAG=1;
        std::cout<< "Stim start value is:--->"<<p_regular_stim->GetStartTime()<<std::endl;
        std::cout<< "Stim magnitude value is:--->"<<p_regular_stim->GetMagnitude()<<std::endl;
        p_regular_stim->SetPeriod(1000);


 /*       ColumnDataReader reader("projects/ApPredict_GP/test/data", "testunlimited",false);
        std::vector<double> t = reader.GetValues("g_Na");
        for(unsigned i = 0; i != t.size(); i++) {

           t[i]=(0-t[i]);
        }
        for(unsigned i = 0; i != t.size(); i++) {
                   std::cout << t[i]<<std::endl<< std::flush;

                }
        double sum_of_elems = std::accumulate(t.begin(), t.end(), 0.0f);
        //std::vector<c_vector<double, 4u> > parameter_values;
        std::cout << "the size is:"<<sum_of_elems<<std::endl<< std::flush;
*/
        /* Run to Limit Cycle */
        SteadyStateRunner steady_runner(p_model);
        steady_runner.SetMaxNumPaces(1000u);
        bool result;
        //result = steady_runner.RunToSteadyState();



        // Start Testing
        std::vector<double> param;
        std::vector<double> blocks;
        /*
        blocks.push_back(0.445998256030947);
        blocks.push_back(0.726700392981565);
        blocks.push_back(0.164843392907217);
        blocks.push_back(0.645151967944316);
        */
        blocks.push_back(0);
        blocks.push_back(1);
        blocks.push_back(1);
        blocks.push_back(1);
        param.push_back(p_model->GetParameter("membrane_fast_sodium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_L_type_calcium_current_conductance"));


        switch (TESTFLAG)
        {

        case 1u:
       /* Test case 1: NO DeP */
        p_model->SetParameter("membrane_fast_sodium_current_conductance", blocks[0]*param[0]);
        p_model->SetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance", blocks[1]*param[1]);
        p_model->SetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance", blocks[2]*param[2]);
        p_model->SetParameter("membrane_L_type_calcium_current_conductance", blocks[3]*param[3]);

        case 2u:
        /* Test case 2: NO ReP */
            p_model->SetParameter("membrane_fast_sodium_current_conductance", blocks[0]*param[0]);
            p_model->SetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance", blocks[1]*param[1]);
            p_model->SetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance", blocks[2]*param[2]);
            p_model->SetParameter("membrane_L_type_calcium_current_conductance", blocks[3]*param[3]);

        case 3u:
        /* Test case 3: Normal AP */
        p_model->SetParameter("membrane_fast_sodium_current_conductance", blocks[0]*param[0]);
        p_model->SetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance", blocks[1]*param[1]);
        p_model->SetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance", blocks[2]*param[2]);
        p_model->SetParameter("membrane_L_type_calcium_current_conductance", blocks[3]*param[3]);

        }
        result = steady_runner.RunToSteadyState();
        TS_ASSERT_EQUALS(result,false);
        p_model->SetTolerances(1e-6,1e-8);
        double max_timestep = 0.5;
        p_model->SetMaxTimestep(max_timestep);
        p_regular_stim->SetStartTime(10);
        double sampling_timestep = 0.1;//max_timestep;
        double start_time = 0.0;
        double end_time = 1000.0;
        OdeSolution solution = p_model->Compute(start_time, end_time, sampling_timestep);

        solution.WriteToFile("TestCvodeCells","ohara_rudy_2011_endoCvode","ms");

        unsigned voltage_index = p_model->GetSystemInformation()->GetStateVariableIndex("membrane_voltage");
        std::vector<double> voltages = solution.GetVariableAtIndex(voltage_index);
        CellProperties cell_props(voltages, solution.rGetTimes(),-50);

        try{
        double apd = cell_props.GetLastActionPotentialDuration(90);
        TS_ASSERT_DELTA(apd, 329.431,0.0070);
                std::cout<< "APD value is:--->"<<apd<<std::endl;
        }
        catch(Exception &e)
        {
            std::cout << e.GetMessage() << std::endl;
        }



        /* Some random tests         */


#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTODESOLVE_HPP_*/

