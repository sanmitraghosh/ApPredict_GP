#ifndef TESTLOOKUPTABLEARCHIVE_HPP_
#define TESTLOOKUPTABLEARCHIVE_HPP_

#include <cxxtest/TestSuite.h>
#include <iostream>
#include <boost/lexical_cast.hpp>

// From Core Chaste
#include "CheckpointArchiveTypes.hpp"
#include "OutputFileHandler.hpp"

// From ApPredict project
#include "LookupTableGenerator.hpp"

//#include "FakePetscSetup.hpp"

class TestLookupTableArchive : public CxxTest::TestSuite
{
public:
    void TestArchive() throw(Exception)
    {
        OutputFileHandler handler("TestLookupTableArchiving_GP",false);

        unsigned model_index = 6u; // O'Hara Rudy (table generated for 1 Hz at present)
        unsigned batchSize = 10u;
        unsigned testSize = 2u; // Remember Evaluation data set size= testSize*batchSize
        unsigned num_evals_before_save = batchSize;
        std::vector<double> NumSimulations;
        LookupTableGenerator<4>* const p_generator =
        						new LookupTableGenerator<4>(model_index, "all_box_points_so_far", "TestLookupTableArchiving_GP");

		p_generator->SetParameterToScale("membrane_fast_sodium_current_conductance", 0.0 , 1.0);
		p_generator->SetParameterToScale("membrane_rapid_delayed_rectifier_potassium_current_conductance", 0.0 , 1.0);
		p_generator->SetParameterToScale("membrane_slow_delayed_rectifier_potassium_current_conductance", 0.0 , 1.0);
		p_generator->SetParameterToScale("membrane_L_type_calcium_current_conductance", 0.0 , 1.0);
		p_generator->SetMaxNumPaces(1000u);
		p_generator->SetPacingFrequency(1.0); // 1Hz
		p_generator->AddQuantityOfInterest(Apd90, 0.5 /*ms*/); // QoI and tolerance to stop refinement

		for(unsigned i=0;i<testSize;i++)
		{
			// Create data structures to store variables to test for equality here
			num_evals_before_save = batchSize*(i+1);
			std::cout << "Running simulations up to " << num_evals_before_save << " evaluations." << std::endl;
			p_generator->SetMaxNumEvaluations(num_evals_before_save);
			p_generator->GenerateLookupTable();

			std::string archive_filename = handler.GetOutputDirectoryFullPath() + "Generator_"
					+ boost::lexical_cast<std::string>(p_generator->GetNumEvaluations()) + "_Evals.arch";
			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			output_arch << p_generator;
			NumSimulations.push_back(p_generator->GetNumEvaluations());
		}

		delete p_generator;

        LookupTableGenerator<4>* p_generatorReader;
        for(unsigned i=0;i<testSize;i++)
        {

            std::string archive_filename = handler.GetOutputDirectoryFullPath() + "Generator_"
                 + boost::lexical_cast<std::string>(NumSimulations[i]) + "_Evals.arch";

            std::cout<<"Filepath is"<<archive_filename<<std::endl;
            // Create an input archive
            std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
            boost::archive::text_iarchive input_arch(ifs);

            // restore from the archive
            std::cout << "Loading from archive " << NumSimulations[i] << " evaluations." << std::endl;
            input_arch >> p_generatorReader;

            std::vector<c_vector<double, 4u> > points = p_generatorReader->GetParameterPoints();
            std::vector<std::vector<double> > values = p_generatorReader->GetFunctionValues();

            TS_ASSERT_EQUALS(points.size(), NumSimulations[i]);
            TS_ASSERT_EQUALS(values.size(), NumSimulations[i]);


        }
        delete p_generatorReader;
    }

 };
#endif /*TESTLOOKUPTABLEARCHIVE_HPP_*/

