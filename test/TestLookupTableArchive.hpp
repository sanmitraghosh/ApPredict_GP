#ifndef TESTLOOKUPTABLEARCHIVE_HPP_
#define TESTLOOKUPTABLEARCHIVE_HPP_

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
#include <boost/lexical_cast.hpp>
class TestLookupTableArchive : public CxxTest::TestSuite
{
public:
    void TestArchive() throw(Exception)
    {

        OutputFileHandler handler("TestLookupTableArchiving_GP",false);
        std::string archive_filename = handler.GetOutputDirectoryFullPath() + "Generator.arch";
        unsigned model_index = 6u; // O'Hara Rudy (table generated for 1 Hz at present)
        unsigned batchSize = 20u;
        unsigned testSize = 2u; // Remember Evaluation data set size= testSize*batchSize
            for(unsigned i=0;i<testSize;i++)
            {
                // Create data structures to store variables to test for equality here
                unsigned num_evals_before_save = batchSize*(i+1);
                {

                    std::string dataSize = boost::lexical_cast<std::string>(num_evals_before_save);
                    std::string file_name ="4d_test_" + dataSize;

                    LookupTableGenerator<4>* const p_generator =
                            new LookupTableGenerator<4>(model_index, file_name, "TestLookupTableArchiving_GP");

                    p_generator->SetParameterToScale("membrane_fast_sodium_current_conductance", 0.0 , 1.0);
                    p_generator->SetParameterToScale("membrane_rapid_delayed_rectifier_potassium_current_conductance", 0.0 , 1.0);
                    p_generator->SetParameterToScale("membrane_slow_delayed_rectifier_potassium_current_conductance", 0.0 , 1.0);
                    p_generator->SetParameterToScale("membrane_L_type_calcium_current_conductance", 0.0 , 1.0);
                    p_generator->SetMaxNumPaces(1000u);
                    p_generator->SetPacingFrequency(1.0); // 1Hz
                    p_generator->AddQuantityOfInterest(Apd90, 0.5 /*ms*/); // QoI and tolerance
                    p_generator->SetMaxNumEvaluations(num_evals_before_save);
                    p_generator->GenerateLookupTable();

                    std::ofstream ofs(archive_filename.c_str());
                    boost::archive::text_oarchive output_arch(ofs);

                    output_arch << p_generator;
                    delete p_generator;

                    std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
                    boost::archive::text_iarchive input_arch(ifs);

                    LookupTableGenerator<4>* p_generatorReader;
                    input_arch >> p_generatorReader;

                    std::vector<c_vector<double, 4u> > points = p_generatorReader->GetParameterPoints();
                    std::vector<std::vector<double> > values = p_generatorReader->GetFunctionValues();

                    TS_ASSERT_EQUALS(points.size(), num_evals_before_save);
                    TS_ASSERT_EQUALS(values.size(), num_evals_before_save);

                    p_generatorReader->SetMaxNumEvaluations(2*num_evals_before_save);
                    p_generatorReader->GenerateLookupTable();

                    points = p_generatorReader->GetParameterPoints();
                    values = p_generatorReader->GetFunctionValues();

                    TS_ASSERT_EQUALS(points.size(), 2*num_evals_before_save);
                    TS_ASSERT_EQUALS(values.size(), 2*num_evals_before_save);

                    delete p_generatorReader;
                }
            }

    }

 };
#endif /*TESTLOOKUPTABLEARCHIVE_HPP_*/

