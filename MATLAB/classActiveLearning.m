
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script gathers actively learnt training data for
    % classifier/boundary prediction. 
    % You can control the following variables to get different
    % behaviour::
    % 1) 'n1'--No. of initial random sampled data
    % 1) 'ns'--Active swarm/particle size. 
    % 1) 'r'--No. active learning rounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
startup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pass al GP related information using the gpoptions structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dimension='4D';
n1=500;
ns=50;
r=4;
STOPCLASS=n1 + r*ns;
gpoptions.ns=ns;
gpoptions.n1=n1;
gpoptions.Dimension=Dimension;
gpoptions.twoStep=0;
gpoptions.pacing=100;
gpoptions.NumInducingClass=300;
gpoptions.sparseMargin=5000;
gpoptions.classHyperParams.minimize=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.paperData=1;  %%% Change this to `0` if you want fresh init data
gpoptions.figurepath=pwd;
if strcmp(Dimension,'2D')
    load('Alearning_2D_10k_Train.mat');
elseif strcmp(Dimension,'4D')
    load('Alearning_4D_100k_Train.mat');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load up a pool of random training data
    % from which we will draw randomly to compare with active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R_random=gk;
y_random=APDtrue;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Sample Initial Random Training Data from the pool loaded earlier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nu = fix(n1); cu = randperm(length(gk)); cu = cu(1:nu); 
R_InitClassTrain=gk(cu,:);
y_InitClassTrain=APDtrue(cu);


%%%%%%%%%%%%%%%%%%%%% This is to replicate paper results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%   Do a few rounds of classifier active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gpoptions.Batch=0;
gpoptions.method='pso'; % Flag to trigger the swarming types or grid ('grid' 'pso')
gpoptions.Model='APD';
gpoptions.STOP=STOPCLASS;
gpoptions.ns=ns;

[ R_ALtrain, y_ALtrain ] = sequentialDesign( R_InitClassTrain, y_InitClassTrain, gpoptions );

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