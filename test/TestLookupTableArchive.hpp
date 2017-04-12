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
        unsigned batchSize = 20u;
        unsigned testSize = 2u; // Remember Evaluation data set size= testSize*batchSize
        unsigned num_evals_before_save = batchSize;

        LookupTableGenerator<4>* const p_generator =
        						new LookupTableGenerator<4>(model_index, file_name, "TestLookupTableArchiving_GP");

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
			p_generator->SetMaxNumEvaluations(num_evals_before_save);
			p_generator->GenerateLookupTable();

			std::string archive_filename = handler.GetOutputDirectoryFullPath() + "Generator_"
					+ boost::lexical_cast<std::string>(p_generator->GetNumEvaluations()) + "_Evals.arch";
			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			output_arch << p_generator;
		}


    }

 };
#endif /*TESTLOOKUPTABLEARCHIVE_HPP_*/

