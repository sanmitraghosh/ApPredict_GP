#ifndef TESTCOMPARECHASTEMAT_HPP_
#define TESTCOMPARECHASTEMAT_HPP_

#include <cxxtest/TestSuite.h>

#include "NumericFileComparison.hpp"
#include "FakePetscSetup.hpp"
#include <iostream>

class TestCompareChasteMat : public CxxTest::TestSuite
{
private:
    bool CalledCollectively;
    bool SuppressOutput;
    bool expected_fail_result;

public:
    void TestCompareChasteVsMatlabFiles() throw(Exception)
    {


        CalledCollectively = true;
        SuppressOutput = true;
        expected_fail_result = !PetscTools::AmMaster();

        std::string chaste_file = "./projects/ApPredict_GP/test/data/chastedata.dat";
        std::string matlab_file = "./projects/ApPredict_GP/test/data/matlabdata.dat";


        NumericFileComparison uptotwodecimal_data(chaste_file, matlab_file, CalledCollectively, SuppressOutput);

        TS_ASSERT(uptotwodecimal.CompareFiles(2e-3, 0, 2e-3, false));

    }
};
#endif /*TESTODESOLVE_HPP_*/

