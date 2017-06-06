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

        std::string base_file = "./projects/ApPredict_GP/test/data/dummy.dat";
        std::string noised_file = "./projects/ApPredict_GP/test/data/dummyplus0.1.dat";

        NumericFileComparison different_data(base_file, noised_file, CalledCollectively, SuppressOutput);
        TS_ASSERT(different_data.CompareFiles(2e-3, 0, 2e-3, false));

    }
};
#endif /*TESTODESOLVE_HPP_*/

