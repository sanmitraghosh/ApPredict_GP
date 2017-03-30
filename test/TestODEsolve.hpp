#ifndef TESTODESOLVE_HPP_
#define TESTODESOLVE_HPP_

#include <cxxtest/TestSuite.h>
#include <boost/shared_ptr.hpp>
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

        unsigned TESTFLAG=3;
        std::cout<< "STim start value is:--->"<<p_regular_stim->GetStartTime()<<std::endl;
        std::cout<< "STim magnitude value is:--->"<<p_regular_stim->GetMagnitude()<<std::endl;
        p_regular_stim->SetPeriod(1000);

        /*
        std::cout << p_cvode_cell->GetSystemName() << std::endl << std::flush;
        std::cout << "Param is ::"<<p_model->GetNumberOfParameters()<<std::endl<< std::flush;
        const std::vector<std::string>par= p_model->rGetParameterNames();
        for(unsigned i = 0; i != par.size(); i++) {
           std::cout << par[i]<<std::endl<< std::flush;
        }
        std::vector<double> param;
        param.push_back(p_model->GetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance"));
        param.push_back(p_model->GetParameter("membrane_fast_sodium_current_conductance"));
        for(unsigned i = 0; i != param.size(); i++) {
           std::cout << param[2]<<std::endl<< std::flush;
        }

        p_model->SetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance", 0.99*param[0]);
        p_model->SetParameter("membrane_fast_sodium_current_conductance", 0.69*param[1]);
        */


        /* Run to Limit Cycle */
        SteadyStateRunner steady_runner(p_model);
        steady_runner.SetMaxNumPaces(10u);
        bool result;
        result = steady_runner.RunToSteadyState();

        TS_ASSERT_EQUALS(result,false);

        // Start Testing
        std::vector<double> param;
        std::vector<double> blocks;
        blocks.push_back(0.782990163368869);
        blocks.push_back(0.423593671196900);
        blocks.push_back(0.836121115158979);
        blocks.push_back(0.593091716207322);
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

        p_model->SetTolerances(1e-6,1e-8);
        double max_timestep = 0.5;
        p_model->SetMaxTimestep(max_timestep);
        p_regular_stim->SetStartTime(0);
        double sampling_timestep = 1;//max_timestep;
        double start_time = 0.0;
        double end_time = 1000.0;
        OdeSolution solution = p_model->Compute(start_time, end_time, sampling_timestep);

        solution.WriteToFile("TestCvodeCells","ohara_rudy_2011_endoCvode","ms");

        unsigned voltage_index = p_model->GetSystemInformation()->GetStateVariableIndex("membrane_voltage");
        std::vector<double> voltages = solution.GetVariableAtIndex(voltage_index);
        CellProperties cell_props(voltages, solution.rGetTimes());

        double apd = cell_props.GetLastActionPotentialDuration(90);
        TS_ASSERT_EQUALS(apd, 399);
        std::cout<< "APD value is:--->"<<apd<<std::endl;
#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTODESOLVE_HPP_*/

