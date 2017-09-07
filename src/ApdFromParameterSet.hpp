/*
Copyright (c) 2005-2017, University of Oxford.
All rights reserved.
University of Oxford means the Chancellor, Masters and Scholars of the
University of Oxford, having an administrative office at Wellington
Square, Oxford OX1 2JD, UK.
This file is part of Chaste.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of the University of Oxford nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef APDFROMPARAMETERSET_HPP_
#define APDFROMPARAMETERSET_HPP_

#include <vector>
#include "FileFinder.hpp"

/**
 * Class to work out APD that will go in Lookup Table / Emulator for a given location
 * in parameter space.
 */
class ApdFromParameterSet
{
private:
    /** Voltage threshold to say NoActionPotential1 - worked out if file giving result isn't present, loaded if it is. */
    double mVoltageThreshold;

    /** Maximum number of paces to run for this experiment */
    unsigned mMaxNumPaces;

    /** Voltage threshold to say NoActionPotential1 - worked out if file giving result isn't present, loaded if it is. */
    std::vector<double> mSteadyStateVariables;

public:
    /**
     * Constructor and method that does all the work.
     *
     * @param rConductanceScalings  scalings to apply, relative to original CellML parameters
     * @param rApd  reference to an empty double to populate/overwrite.
     * @param pFileFinder  if a file finder is provided, we write the APs out to this folder.
     */
    ApdFromParameterSet(const std::vector<double>& rConductanceScalings,
                        double& rApd,
                        FileFinder* pFileFinder = nullptr);
};

#endif /*APDFROMPARAMETERSET_HPP_*/
