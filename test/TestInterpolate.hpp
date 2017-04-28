#ifndef TESTINTERPOLATE_HPP_
#define TESTINTERPOLATE_HPP_

#include <cxxtest/TestSuite.h>
#include <boost/shared_ptr.hpp>
#include <boost/assign/list_of.hpp>
#include <ColumnDataReader.hpp>
#include <ColumnDataWriter.hpp>

#include "CheckpointArchiveTypes.hpp"

#include "LookupTableGenerator.hpp"
#include "LookupTableReader.hpp"


//#include "FakePetscSetup.hpp"
#include <iostream>
#include <fstream>
#include <cmath>
#include <numeric>
#include <boost/lexical_cast.hpp>
class TestInterpolate : public CxxTest::TestSuite
{
private:
    ColumnDataWriter* mpTestWriter;
    ColumnDataReader* mpTestReader;
public:
   void TestInterpolateVsGPfromArchive() throw(Exception)
        {
                std::vector<double> L1error;
                //unsigned APDTestSetSize=10u;
                ColumnDataReader reader("projects/ApPredict_GP/test/data", "matlabdata",false);

                std::vector<double> Block_gNa = reader.GetValues("g_Na");
                std::vector<double> Block_gKr = reader.GetValues("g_Kr");
                std::vector<double> Block_gKs = reader.GetValues("g_Ks");
                std::vector<double> Block_gCal = reader.GetValues("g_CaL");
                //std::vector<double> MATLABapd = reader.GetValues("MatAPD");
                mpTestReader = new ColumnDataReader("TestGenerateApdTestSet", "writeAPD");
                std::vector<double> CHASTEapd = mpTestReader->GetValues("APD");
                mpTestWriter = new ColumnDataWriter("InterpolationError", "InterpolationError", false);
                int time_var_id = 0;
                int interperr_var_id = 0;
                unsigned conf_box_one = 0;
                unsigned conf_box_two = 0;
                unsigned conf_box_three = 0;
                unsigned conf_box_four = 0;
                unsigned conf_box_five = 0;
                unsigned conf_box_six = 0;
                unsigned conf_box_seven = 0;
                unsigned conf_box_eight = 0;
                unsigned conf_box_nine = 0;

                TS_ASSERT_THROWS_NOTHING(time_var_id = mpTestWriter->DefineUnlimitedDimension("TestPointIndex","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(interperr_var_id = mpTestWriter->DefineVariable("LoneError","milliseconds"));
                TS_ASSERT_THROWS_NOTHING(conf_box_one = mpTestWriter->DefineVariable("APAP","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(conf_box_two = mpTestWriter->DefineVariable("APNoDep","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(conf_box_three = mpTestWriter->DefineVariable("APNoRep","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(conf_box_four = mpTestWriter->DefineVariable("NoDepAP","dimensionless"));//chamge this to meaningful names
                TS_ASSERT_THROWS_NOTHING(conf_box_five = mpTestWriter->DefineVariable("NoDepNoDep","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(conf_box_six = mpTestWriter->DefineVariable("NoDepNoRep","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(conf_box_seven = mpTestWriter->DefineVariable("NoRepAP","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(conf_box_eight = mpTestWriter->DefineVariable("NoRepNoDep","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(conf_box_nine = mpTestWriter->DefineVariable("NoRepNoRep","dimensionless"));
                TS_ASSERT_THROWS_NOTHING(mpTestWriter->EndDefineMode());

                //Now generate lookupTables of diff sizes and save them to disk

                std::vector<c_vector<double, 4u> > parameter_values; // 4-D vector of parameter values
                for(unsigned i=0;i<Block_gNa.size();i++)//Block_gNa.size()
                {
                    c_vector<double,4u> blocks;
                    blocks[0]=Block_gNa[i];
                    blocks[1]=Block_gKr[i];
                    blocks[2]=Block_gKs[i];
                    blocks[3]=Block_gCal[i];
                    parameter_values.push_back(blocks);
                }

                // remove those points with No AP
/*                for(unsigned i=0;i<Block_gNa.size();i++)
                {
                    if (fabs(CHASTEapd[i]) < 1e-12 || fabs(CHASTEapd[i] - 1000)<1e-12)
                    {
                        CHASTEapd.erase(CHASTEapd.begin()+i);
                        parameter_values.erase(parameter_values.begin()+i);
                    }

                }
*/
                OutputFileHandler handler("TestLookupTableArchiving_GP",false);
                // Load the number of simulations that were performed.
                std::string archive_filename_num_evals = handler.GetOutputDirectoryFullPath() + "NumbersOfEvaluations.arch";
                std::ifstream ifs_num_evals(archive_filename_num_evals.c_str(), std::ios::binary);
                boost::archive::text_iarchive input_arch_num_evals(ifs_num_evals);

                std::vector<unsigned> num_evaluations;
                input_arch_num_evals >> num_evaluations;
                std::vector<double> L1dist;
                double Error;

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


                    // Interpolate ********* Gary pls Check********************
                    std::vector<std::vector<double> > apd_values = p_generator_read_in->Interpolate(parameter_values);
                    TS_ASSERT_EQUALS(apd_values.size(),parameter_values.size());

                    std::cout << "CHASTEapd Test Size:"<<CHASTEapd.size()<<std::endl<< std::flush;
                    std::cout << "APD interpolate Size:"<<apd_values.size()<<std::endl<< std::flush;
                    //Implement L1 error
                    unsigned c1=0u, c2=0u, c3=0u, c4=0u, c5=0u, c6=0u, c7=0u, c8=0u, c9=0u;
                        for(unsigned j=0;j<apd_values.size();j++)
                        {
                            if (fabs(CHASTEapd[j]) > 1e-12 && fabs(CHASTEapd[j] - 1000)>1e-12)
                            {
                                if (fabs(apd_values[j][0]) > 1e-12 && fabs(apd_values[j][0] - 1000)>1e-12)
                                {L1dist.push_back(std::abs(CHASTEapd[j]-apd_values[j][0]));
                                c1++;}
                                else if (fabs(apd_values[j][0])<1e-12){c2++;}
                                else {c3++;}
                            }

                            else if (fabs(CHASTEapd[j])<1e-12)
                            {
                                if (fabs(CHASTEapd[j])<1e-12){c5++;}
                                else if (fabs(apd_values[j][0] - 1000)<1e-12) {c6++;}
                                else {c4++;}
                            }
                            else if (fabs(CHASTEapd[j] - 1000)<1e-12)
                            {
                                if (fabs(apd_values[j][0] - 1000)<1e-12){c9++;}
                                else if (fabs(apd_values[j][0])<1e-12) {c8++;}
                                else {c7++;}
                            }


                        }
                        std::cout << "AP--AP---> \t"<<c1<<std::endl<< std::flush;
                        std::cout << "AP---0---> \t"<<c2<<std::endl<< std::flush;
                        std::cout << "AP---1000---> \t"<<c3<<std::endl<< std::flush;
                        std::cout << "0---AP---> \t"<<c4<<std::endl<< std::flush;
                        std::cout << "0---0---> \t"<<c5<<std::endl<< std::flush;
                        std::cout << "0---1000---> \t"<<c6<<std::endl<< std::flush;
                        std::cout << "1000---AP---> \t"<<c7<<std::endl<< std::flush;
                        std::cout << "1000---0---> \t"<<c8<<std::endl<< std::flush;
                        std::cout << "10000---1000---> \t"<<c9<<std::endl<< std::flush;
                      Error=(std::accumulate(L1dist.begin(), L1dist.end(), 0.0f) )/L1dist.size();
                     L1error.push_back(Error);
                     std::cout << "The error Interpolate Vs GP is: \n"<<Error<<std::endl<< std::flush;
                     mpTestWriter->PutVariable(time_var_id, i+1);
                     mpTestWriter->PutVariable(interperr_var_id, Error);
                     mpTestWriter->PutVariable(conf_box_one, c1);

                     mpTestWriter->PutVariable(conf_box_two, c2);
                     mpTestWriter->PutVariable(conf_box_three, c3);
                     mpTestWriter->PutVariable(conf_box_four, c4);
                     mpTestWriter->PutVariable(conf_box_five, c5);
                     mpTestWriter->PutVariable(conf_box_six, c6);
                     mpTestWriter->PutVariable(conf_box_seven, c7);
                     mpTestWriter->PutVariable(conf_box_eight, c8);
                     mpTestWriter->PutVariable(conf_box_nine, c9);
                     mpTestWriter->AdvanceAlongUnlimitedDimension();

                    std::vector<c_vector<double, 4u> > points = p_generator_read_in->GetParameterPoints();
                    std::vector<std::vector<double> > values = p_generator_read_in->GetFunctionValues();

                    TS_ASSERT_EQUALS(points.size(), num_evaluations[i]);
                    TS_ASSERT_EQUALS(values.size(), num_evaluations[i]);

                    delete p_generator_read_in;
                }
                delete mpTestWriter;
                delete mpTestReader;
        }
 };
#endif /*TESTINTERPOLATE_HPP_*/

