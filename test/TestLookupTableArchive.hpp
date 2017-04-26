#ifndef TESTLOOKUPTABLEARCHIVE_HPP_
#define TESTLOOKUPTABLEARCHIVE_HPP_

#include <cxxtest/TestSuite.h>

#include <boost/assign/list_of.hpp>
#include <ColumnDataReader.hpp>
#include <ColumnDataWriter.hpp>

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
        // This is the file handling bit
        OutputFileHandler handler("TestLookupTableArchiving_GP",false);
        unsigned model_index = 6u; // O'Hara Rudy (table generated for 1 Hz at present)
        unsigned batchSize = 1000u;
        unsigned testSize = 8u; // Remember Evaluation data set size= testSize*batchSize
        unsigned num_evals_before_save = batchSize;
        unsigned Init_Pace=100u;
        std::vector<unsigned> num_simulations;
        LookupTableGenerator<4>* const p_generator =
        						new LookupTableGenerator<4>(model_index, "all_box_points_so_far", "TestLookupTableArchiving_GP");

		p_generator->SetParameterToScale("membrane_fast_sodium_current_conductance", 0.0 , 1.0);
		p_generator->SetParameterToScale("membrane_rapid_delayed_rectifier_potassium_current_conductance", 0.0 , 1.0);
		p_generator->SetParameterToScale("membrane_slow_delayed_rectifier_potassium_current_conductance", 0.0 , 1.0);
		p_generator->SetParameterToScale("membrane_L_type_calcium_current_conductance", 0.0 , 1.0);
		p_generator->SetMaxNumPaces(Init_Pace);
		p_generator->SetPacingFrequency(1.0); // 1Hz
		p_generator->AddQuantityOfInterest(Apd90, 0.5 /*ms*/); // QoI and tolerance to stop refinement

		for(unsigned i=0;i<testSize;i++)
		{
			// Create data structures to store variables to test for equality here
			num_evals_before_save = batchSize*(i+1);
			std::cout << "Running simulations up to " << num_evals_before_save << " evaluations." << std::endl;
			p_generator->SetMaxNumEvaluations(num_evals_before_save);
			p_generator->GenerateLookupTable();
			num_simulations.push_back(p_generator->GetNumEvaluations());

			// Now archive the Lookup Tables.
			std::string archive_filename = handler.GetOutputDirectoryFullPath() + "Generator_"
					+ boost::lexical_cast<std::string>(p_generator->GetNumEvaluations()) + "_Evals.arch";
			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			output_arch << p_generator;

		}

		delete p_generator;
        // Now archive the number of simulations that were performed.
        std::string archive_filename_num_evals = handler.GetOutputDirectoryFullPath() + "NumbersOfEvaluations.arch";
        std::ofstream ofs_2(archive_filename_num_evals.c_str());
        boost::archive::text_oarchive output_arch_2(ofs_2);
        output_arch_2 << num_simulations;


    }

 };
#endif /*TESTLOOKUPTABLEARCHIVE_HPP_*/

