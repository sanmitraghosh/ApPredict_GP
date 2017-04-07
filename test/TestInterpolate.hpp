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
            Block_gNa[i]=Block_gNa[i]*p_model->GetParameter("membrane_L_type_calcium_current_conductance");
        }

        //******* Gary pls Check********************
        std::vector<c_vector<double, 4u> > parameter_values; // 4-D vector of parameter values

        for(unsigned i=0;i<=parameter_values.size();i++)
        {
            parameter_values[i][0]=Block_gNa[i];
            parameter_values[i][1]=Block_gKr[i];
            parameter_values[i][2]=Block_gKs[i];
            parameter_values[i][3]=Block_gNa[i];

        }
        // Get the generator ready
        unsigned model_index = 9u;// O'Hara Rudy (table generated for 1 Hz at present)etModel();

        std::string file_name = "4d_test";
        LookupTableGenerator<4> generator(model_index, file_name, "TestLookupTables");
        generator.SetMaxNumPaces(1000u);
        generator.SetPacingFrequency(1000);// I hope this gives the regularstim SetPeriod type
        generator.SetMaxNumEvaluations(5u);// restrict to 5 ODE evaluations & ask to predict on all 10 points
        generator.AddQuantityOfInterest(Apd90, 0.5 /*ms*/);

        // Interpolate ********* Gary pls Check********************
        std::vector<std::vector<double> > apdValues=generator.Interpolate(parameter_values);
        std::vector<double> L1dist;

        //Implement L1 error with matlab
        for(unsigned i=0;i<=apdValues.size();i++)
        {
            L1dist[i]=std::abs(MATLABapd[i]-apdValues[0][i]);
        }
        double L1error = (std::accumulate(L1dist.begin(), L1dist.end(), 0.0f) )/L1dist.size();
        std::cout << "The error Interpolate Vs GP is:"<<L1error<<std::endl<< std::flush;

    }
};
#endif /*TESTINTERPOLATEVSGP_HPP_*/

