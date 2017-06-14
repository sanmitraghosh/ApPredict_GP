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

// From this project
#include "ApdFromParameterSet.hpp"

// From ApPredict project
#include "LookupTableGenerator.hpp"
#include "SetupModel.hpp"
#include "SingleActionPotentialPrediction.hpp"

// From Core Chaste
#include "Exception.hpp"

ApdFromParameterSet::ApdFromParameterSet(const std::vector<double>& rConductanceScalings, double& rApd)
        : mVoltageThreshold(DBL_MAX),
          mMaxNumPaces(100)
{
    // Parameters of interest
    std::vector<std::string> parameter_names;
    parameter_names.push_back("membrane_fast_sodium_current_conductance");
    parameter_names.push_back("membrane_rapid_delayed_rectifier_potassium_current_conductance");
    parameter_names.push_back("membrane_slow_delayed_rectifier_potassium_current_conductance");
    parameter_names.push_back("membrane_L_type_calcium_current_conductance");

    EXCEPT_IF_NOT(parameter_names.size() == rConductanceScalings.size());

    // Use helper method from ApPredict to set up the model.
    SetupModel setup(1.0, 6u); // O'Hara at 1 Hz
    boost::shared_ptr<AbstractCvodeCell> p_model = setup.GetModel();

    // Save original model parameters
    std::vector<double> param;
    for (unsigned i = 0; i < parameter_names.size(); i++)
    {
        param.push_back(p_model->GetParameter(parameter_names[i]));
    }

    // Now look to see whether we have already worked out steady state and voltage threshold
    //if ()
    {
        SteadyStateRunner steady_runner(p_model);
        steady_runner.SuppressOutput();
        steady_runner.RunToSteadyState();

        // Record these initial conditions (we'll always start from these).
        mSteadyStateVariables = MakeStdVec(p_model->rGetStateVariables());

        // We now do a special run of a model with sodium current set to zero, so we
        // can see the effect of simply a stimulus current, and then set the threshold
        // for APs accordingly.
        mVoltageThreshold = LookupTableGenerator<4>::DetectVoltageThresholdForActionPotential(p_model);
    }
    //    else
    //    {
    //    }

    // Do parameter scalings
    for (unsigned i = 0; i < rConductanceScalings.size(); i++)
    {
        p_model->SetParameter(parameter_names[i], param[i] * rConductanceScalings[i]);
    }

    // Reset the state variables to the 'standard' steady state
    p_model->SetStateVariables(mSteadyStateVariables);

    SingleActionPotentialPrediction ap_runner(p_model);
    ap_runner.SuppressOutput();
    ap_runner.SetMaxNumPaces(mMaxNumPaces);
    ap_runner.SetLackOfOneToOneCorrespondenceIsError();
    ap_runner.SetVoltageThresholdForRecordingAsActionPotential(mVoltageThreshold);
    ap_runner.RunSteadyPacingExperiment();

    // Record the results
    if (ap_runner.DidErrorOccur())
    {
        std::string error_message = ap_runner.GetErrorMessage();
        // We could use different numerical codes for different errors here if we wanted to.
        if (error_message == "NoActionPotential_2" || error_message == "NoActionPotential_3")
        {
            // For an APD calculation failure on repolarisation put in the stimulus
            // period.
            double stim_period = boost::static_pointer_cast<RegularStimulus>(p_model->GetStimulusFunction())->GetPeriod();
            rApd = stim_period;
        }
        else
        {
            // For everything else (failure to depolarize "NoActionPotential_1")
            // just put in zero for now.
            rApd = 0.0;
        }
    }
    else
    {
        rApd = ap_runner.GetApd90();
    }
}
