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
        std::vector<unsigned> num_simulations;
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
			num_simulations.push_back(p_generator->GetNumEvaluations());

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


    // This should be a completely independent test (with no member variables carried across)
    // to check that we can still load up these generators with a fresh simulation later on.
    void TestLoadingGenerators() throw(Exception)
    {
    	OutputFileHandler handler("TestLookupTableArchiving_GP",false);

    	// Load the number of simulations that were performed.
    	std::string archive_filename_num_evals = handler.GetOutputDirectoryFullPath() + "NumbersOfEvaluations.arch";
    	std::ifstream ifs_num_evals(archive_filename_num_evals.c_str(), std::ios::binary);
    	boost::archive::text_iarchive input_arch_num_evals(ifs_num_evals);

    	std::vector<unsigned> num_evaluations;
    	input_arch_num_evals >> num_evaluations;


        for(unsigned i=0;i<num_evaluations.size();i++)
        {
        	LookupTableGenerator<4>* p_generator_read_in;

            std::string archive_filename = handler.GetOutputDirectoryFullPath() + "Generator_"
                 + boost::lexical_cast<std::string>(num_evaluations[i]) + "_Evals.arch";

            std::cout<<"Filepath is"<<archive_filename<<std::endl;
            // Create an input archive
            std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
            boost::archive::text_iarchive input_arch(ifs);

            // restore from the archive
            std::cout << "Loading from archive " << num_evaluations[i] << " evaluations." << std::endl;
            input_arch >> p_generator_read_in;

            std::vector<c_vector<double, 4u> > points = p_generator_read_in->GetParameterPoints();
            std::vector<std::vector<double> > values = p_generator_read_in->GetFunctionValues();

            TS_ASSERT_EQUALS(points.size(), num_evaluations[i]);
            TS_ASSERT_EQUALS(values.size(), num_evaluations[i]);

            delete p_generator_read_in;
        }

    }

 };
#endif /*TESTLOOKUPTABLEARCHIVE_HPP_*/

