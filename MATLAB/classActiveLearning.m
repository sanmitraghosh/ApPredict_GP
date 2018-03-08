
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script gathers actively learnt training data for
    % classifier/boundary prediction. This corresponds to the Fig4 in the paper.
    % You can control the following variables to get different
    % behaviour::
    % 1) 'n1'--No. of initial random sampled data
    % 1) 'ns'--Active swarm/particle size. For surface fix this to 1
    % 1) 'r'--No. active learning r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
startup
load('Alearning_2D_10k_Train.mat');%Change this with 'Alearning_4D_100k_Train.mat' for 4D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pass al GP related information using the gpoptions structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n1=100;
ns=25;
r=20;
STOPCLASS=n1 + r*ns;
gpoptions.ns=ns;
gpoptions.n1=n1;
gpoptions.twoStep=0;
gpoptions.pacing=100;
gpoptions.NumInducingClass=300;
gpoptions.sparseMargin=5000;
gpoptions.classHyperParams.minimize=0;
gpoptions.paperData=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load up a pool of random training data
    % from which we will draw randomely to compare with active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R_random=gk;
y_random=APDtrue;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Sample Initial Random Training Data from the pool loaded earlier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nu = fix(n1); cu = randperm(length(gk)); cu = cu(1:nu); 
R_InitClassTrain=gk(cu,:);
y_InitClassTrain=APDtrue(cu);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Load Initial Random Training Data from results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if gpoptions.paperData ==1
    if size(R_random,2)==2
        initData=load('./data/2D/classActive2DpaperInit.mat');
    else
        initData=load('./data/4D/classActive4DpaperInit.mat');
    end

    R_InitClassTrain=initData.R_Initrandom;
    y_InitClassTrain=initData.y_Initrandom;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Learn hyperparameters for classifier active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
gpoptions.LearningMode='classifier';
outparam= learnGPhyp( R_InitClassTrain, y_InitClassTrain, gpoptions );
gpoptions.classHyperParams=outparam;
thyp=toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Do a few r of classifier active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.Batch=0;
gpoptions.method='pso'; % Flag to trigger the swarming types or grid ('grid' 'pso' 'ga')
gpoptions.Model='APD';
gpoptions.STOP=STOPCLASS;
gpoptions.ns=ns;

[ R_ALtrain, y_ALtrain ] = sequentialDesign( R_InitClassTrain, y_InitClassTrain, gpoptions );
% tintelli=dlmread('Telapsed.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Remove the initial points from the pool of random training data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R_random(cu,:)=[];
y_random(cu)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Save the dataset, please rename accordingly!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('classActiveCurrent.mat')
% Clean-up
command='rm -rf *.txt';
system(command);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Call up evaluation script to compare with random learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classActiveLearningtest