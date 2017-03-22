#ifndef TESTODESOLVE_HPP_
#define TESTODESOLVE_HPP_

#include <cxxtest/TestSuite.h>
#include "CellProperties.hpp"
#include "SteadyStateRunner.hpp"
#include "AbstractCvodeCell.hpp"
#include "RegularStimulus.hpp"
#include "EulerIvpOdeSolver.hpp"
#include "Shannon2004Cvode.hpp"
#include "ohara_rudy_2011_endo.hpp"
#include "ohara_rudy_2011_endoOpt.hpp"
#include "ohara_rudy_2011_endoCvode.hpp"
#include "ohara_rudy_2011_endoCvodeOpt.hpp"
#include "FakePetscSetup.hpp"
#include <iostream>

class TestSingleCellTutorial : public CxxTest::TestSuite
{
public:
    void TestShannonSimulation() throw(Exception)
    {
#ifdef CHASTE_CVODE
        boost::shared_ptr<RegularStimulus> p_stimulus;
        boost::shared_ptr<AbstractIvpOdeSolver> p_solver;
        boost::shared_ptr<AbstractCvodeCell> p_model(new Cellohara_rudy_2011_endoFromCellMLCvode(p_solver, p_stimulus));

        boost::shared_ptr<RegularStimulus> p_regular_stim = p_model->UseCellMLDefaultStimulus();

        p_regular_stim->SetPeriod(1000.0);
        std::cout << "Param is.\n"<<p_model->GetParameter("membrane_persistent_sodium_current_conductance")<<"\n";
        double kparam = p_model->GetParameter("membrane_persistent_sodium_current_conductance");
        p_model->SetParameter("membrane_persistent_sodium_current_conductance", 0.1*kparam);
        SteadyStateRunner steady_runner(p_model);
        steady_runner.SetMaxNumPaces(100u);
        bool result;
        result = steady_runner.RunToSteadyState();

        TS_ASSERT_EQUALS(result,false);

        double max_timestep = 0.1;
        p_model->SetMaxTimestep(max_timestep);

        double sampling_timestep = max_timestep;
        double start_time = 0.0;
        double end_time = 1000.0;
        OdeSolution solution = p_model->Compute(start_time, end_time, sampling_timestep);

        solution.WriteToFile("TestCvodeCells","ohara_rudy_2011_endoCvode","ms");

        unsigned voltage_index = p_model->GetSystemInformation()->GetStateVariableIndex("membrane_voltage");
        std::vector<double> voltages = solution.GetVariableAtIndex(voltage_index);
        CellProperties cell_props(voltages, solution.rGetTimes());

        double apd = cell_props.GetLastActionPotentialDuration(90);
        std::cout << "APD value is.\n"<<apd;
//        TS_ASSERT_DELTA(apd, 212.41, 1e-2);
//      TS_ASSERT_DELTA(upstroke_velocity, 338, 1.25);

#else
        std::cout << "Cvode is not enabled.\n";
#endif
    }
};
#endif /*TESTODESOLVE_HPP_*/

