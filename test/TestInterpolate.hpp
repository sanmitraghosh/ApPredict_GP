#ifndef TESTINTERPOLATEVSGP_HPP_
#define TESTINTERPOLATEVSGP_HPP_

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
#include "CheckpointArchiveTypes.hpp"

#include "SetupModel.hpp"
#include "SingleActionPotentialPrediction.hpp"
#include "LookupTableGenerator.hpp"
#include "LookupTableReader.hpp"

#include "ohara_rudy_2011_endoCvode.hpp"
//#include "FakePetscSetup.hpp"
#include <iostream>
#include <fstream>
#include <cmath>
#include <numeric>
class TestInterpolateVsGP : public CxxTest::TestSuite
{
public:
    void TestInterpolate() throw(Exception)
    {
        // Define the O'hara model
        boost::shared_ptr<RegularStimulus> p_stimulus;
        boost::shared_ptr<EulerIvpOdeSolver> p_solver;
        boost::shared_ptr<AbstractCvodeCell> p_model(new Cellohara_rudy_2011_endoFromCellMLCvode(p_solver, p_stimulus));

        //Read the blocking values as generated in MATLAB

        ColumnDataReader reader("projects/ApPredict_GP/test/data", "testunlimited",false);
        std::vector<double> Block_gNa = reader.GetValues("g_Na");
        std::vector<double> Block_gKr = reader.GetValues("g_Kr");
        std::vector<double> Block_gKs = reader.GetValues("g_Ks");
        std::vector<double> Block_gCal = reader.GetValues("g_CaL");
        std::vector<double> MATLABapd = reader.GetValues("MatAPD");


        for (unsigned i=0;i<=Block_gNa.size();i++)
        {
            Block_gNa[i]=Block_gNa[i]*p_model->GetParameter("membrane_fast_sodium_current_conductance");
            Block_gKr[i]=Block_gKr[i]*p_model->GetParameter("membrane_rapid_delayed_rectifier_potassium_current_conductance");
            Block_gKs[i]=Block_gKs[i]*p_model->GetParameter("membrane_slow_delayed_rectifier_potassium_current_conductance");
            Block_gNa[i]=Block_gCal[i]*p_model->GetParameter("membrane_L_type_calcium_current_conductance");
        }

        std::vector<c_vector<double, 4u> > parameter_values; // 4-D vector of parameter values
        for(unsigned i=0;i<=Block_gNa.size();i++)
        {
        	c_vector<double,4u> blocks;
            blocks[0]=Block_gNa[i];
            blocks[1]=Block_gKr[i];
            blocks[2]=Block_gKs[i];
            blocks[3]=Block_gCal[i];
            parameter_values.push_back(blocks);
        }
        
        // Get the generator ready
        unsigned model_index = 6u;// O'Hara Rudy (table generated for 1 Hz at present)

        std::string file_name = "4d_test";
        LookupTableGenerator<4> generator(model_index, file_name, "TestApPredict_GPInterpolate");
        
        // N.B. These have to be in same order as the 'block' vector above for the lookup to make any sense.
        generator.SetParameterToScale("membrane_fast_sodium_current_conductance", 0.0 , 1.0);
        generator.SetParameterToScale("membrane_rapid_delayed_rectifier_potassium_current_conductance", 0.0 , 1.0);
        generator.SetParameterToScale("membrane_slow_delayed_rectifier_potassium_current_conductance", 0.0 , 1.0);
        generator.SetParameterToScale("membrane_L_type_calcium_current_conductance", 0.0 , 1.0);
                
        generator.SetMaxNumPaces(1000u);
        generator.SetPacingFrequency(1.0); // 1Hz
        generator.SetMaxNumEvaluations(5u); // restrict to 5 ODE evaluations (N.B. it will evaluate more as it does all the corners first.)
        generator.AddQuantityOfInterest(Apd90, 0.5 /*ms*/);
        
        generator.GenerateLookupTable();

        // Interpolate ********* Gary pls Check********************
        std::vector<std::vector<double> > apd_values = generator.Interpolate(parameter_values);
        std::vector<double> L1dist;

        //Implement L1 error with matlab
        for(unsigned i=0;i<=apd_values.size();i++)
        {
            L1dist[i]=std::abs(MATLABapd[i]-apd_values[i][0]);
        }
        double L1error = (std::accumulate(L1dist.begin(), L1dist.end(), 0.0f) )/L1dist.size();
        std::cout << "The error Interpolate Vs GP is:"<<L1error<<std::endl<< std::flush;

    }
};
#endif /*TESTINTERPOLATEVSGP_HPP_*/

