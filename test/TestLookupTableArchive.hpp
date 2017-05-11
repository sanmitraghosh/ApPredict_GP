#ifndef TESTLOOKUPTABLEARCHIVE_HPP_
#define TESTLOOKUPTABLEARCHIVE_HPP_

#include <cxxtest/TestSuite.h>

#include <boost/lexical_cast.hpp>
#include <cmath>
#include <fstream>
#include <iostream>
#include <numeric>

#include "CheckpointArchiveTypes.hpp"

#include "LookupTableGenerator.hpp"

const unsigned DIM = 4u;

class TestLookupTableArchive : public CxxTest::TestSuite
{
public:
    void TestArchive() throw(Exception)
    {
        // This is the file handling bit
        OutputFileHandler handler("TestLookupTableArchiving_GP", false);
        unsigned model_index = 6u; // O'Hara Rudy (table generated for 1 Hz at present)
        unsigned evals_per_loop = 20 * pow(2, DIM); // Min Number of evaluations to add on each loop
        unsigned num_loops = 100u; // Remember Evaluation data set size= testSize*batchSize
        unsigned max_num_paces = 100u; // TODO: change to 1000, but this OK for speed for now.
        std::vector<unsigned> num_simulations;

        LookupTableGenerator<DIM>* p_generator;
        if (CommandLineArguments::Instance()->OptionExists("--run-from"))
        {
            // Have a look for pre-existing archives to extend...
            unsigned archive_num_evals_to_load = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("--run-from");
            std::string archive_filename = handler.GetOutputDirectoryFullPath() + "Generator_" + boost::lexical_cast<std::string>(archive_num_evals_to_load) + "_Evals.arch";

            // Create an input archive
            std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
            boost::archive::text_iarchive input_arch(ifs);

            // restore from the archive
            input_arch >> p_generator;

            std::cout << "Loaded archive " << archive_filename
                      << " and building on that." << std::endl;

            // Now un-archive the number of simulations that were performed.
            std::string archive_filename_num_evals = handler.GetOutputDirectoryFullPath() + "NumbersOfEvaluations.arch";
            std::ifstream ifs_2(archive_filename_num_evals.c_str(), std::ios::binary);
            boost::archive::text_iarchive input_arch_2(ifs_2);
            input_arch_2 >> num_simulations;

            if (num_simulations.back() != p_generator->GetNumEvaluations())
            {
                EXCEPTION("A later archive of " << num_simulations.back() << " exists, please use that instead.");
            }
        }
        else
        {
            // Start a completely new LookupTableGenerator
            p_generator = new LookupTableGenerator<4>(model_index, "all_box_points_so_far", "TestLookupTableArchiving_GP");

            p_generator->SetParameterToScale("membrane_fast_sodium_current_conductance", 0.0, 1.0);
            p_generator->SetParameterToScale("membrane_rapid_delayed_rectifier_potassium_current_conductance", 0.0, 1.0);
            p_generator->SetParameterToScale("membrane_slow_delayed_rectifier_potassium_current_conductance", 0.0, 1.0);
            p_generator->SetParameterToScale("membrane_L_type_calcium_current_conductance", 0.0, 1.0);
            p_generator->SetMaxNumPaces(max_num_paces);
            p_generator->SetPacingFrequency(1.0); // 1Hz
            p_generator->AddQuantityOfInterest(Apd90, 0.5 /*ms*/); // QoI and tolerance to stop refinement
            p_generator->SetMaxVariationInRefinement(7u); // This prevents over-refining in one area.
        }

        for (unsigned i = 0; i < num_loops; i++)
        {
            // Create data structures to store variables to test for equality here
            p_generator->SetMaxNumEvaluations(p_generator->GetNumEvaluations() + evals_per_loop);
            std::cout << "Running simulations from "
                      << p_generator->GetNumEvaluations() << " up to "
                      << p_generator->GetNumEvaluations() + evals_per_loop << " evaluations." << std::endl;
            p_generator->GenerateLookupTable();
            std::cout << "Simulations complete, lookup table extended to "
                      << p_generator->GetNumEvaluations() << " evaluations."
                      << std::endl;
            num_simulations.push_back(p_generator->GetNumEvaluations());

            // Now archive the Lookup Tables.
            std::string archive_filename = handler.GetOutputDirectoryFullPath() + "Generator_" + boost::lexical_cast<std::string>(p_generator->GetNumEvaluations()) + "_Evals.arch";

            // Overwrite archive entry, should archive pointers as const.
            {
                LookupTableGenerator<DIM>* const p_arch_generator = p_generator;

                std::ofstream ofs(archive_filename.c_str());
                boost::archive::text_oarchive output_arch(ofs);

                output_arch << p_arch_generator;
            }

            {
                // Now archive the number of simulations that were performed.
                std::string archive_filename_num_evals = handler.GetOutputDirectoryFullPath() + "NumbersOfEvaluations.arch";
                std::ofstream ofs_2(archive_filename_num_evals.c_str());
                boost::archive::text_oarchive output_arch_2(ofs_2);
                output_arch_2 << num_simulations;
            }
        }

        std::cout << "Deleting p_generator" << std::endl;

        delete p_generator;

        std::cout << "Deleted" << std::endl;
    }
};

#endif /*TESTLOOKUPTABLEARCHIVE_HPP_*/
