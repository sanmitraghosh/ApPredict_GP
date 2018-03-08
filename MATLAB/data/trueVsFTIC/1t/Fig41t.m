
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script gathers actively learnt training data for
    % classifier/boundary prediction. This corresponds to the Fig4 in the paper.
    % You can control the following variables to get different
    % behaviour::
    % 1) 'CScale'--No. of initial random sampled data
    % 1) 'AScale'--Active swarm/particle size. For surface fix this to 1
    % 1) 'Rounds'--No. active learning rounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
startup
load('Alearning_4D_100k_Train.mat');%Change this with 'Alearning_4D_100k_Train.mat' for 4D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pass al GP related information using the gpoptions structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CScale=500;
AScale=50;
Rounds=30;
STOPCLASS=CScale + Rounds*AScale;
gpoptions.pacing=100;
gpoptions.NumInducingClass=300;
gpoptions.sparseMargin=5000;
gpoptions.classHyperParams.minimize=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load up a pool of random training data
    % from which we will draw randomely to compare with active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X_train=gk;
Y_train=APDtrue;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Load Initial Random Training Data from results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initData=load('init1.mat');
x_InitTrain=initData.X_init;
y_InitTrain=initData.Y_init;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Learn hyperparameters for classifier active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
gpoptions.LearningMode='classifier';
outparam= learnGPhyp( x_InitTrain, y_InitTrain, gpoptions );
gpoptions.classHyperParams=outparam;
thyp=toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Do a few rounds of classifier active learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
gpoptions.Batch=0;
gpoptions.method='pso'; % Flag to trigger the swarming types or grid ('grid' 'pso' 'ga')
gpoptions.Model='APD';
gpoptions.STOP=STOPCLASS;
gpoptions.AScale=AScale;
[ x_train, y_train ] = intelligentTraining( x_InitTrain, y_InitTrain, gpoptions );

tintelli=dlmread('Telapsed.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Remove the initial points from the pool of random training data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X_train(cu,:)=[];
Y_train(cu)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Save the dataset, please rename accordingly!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('classActive4D1t.mat')
% Clean-up
command='rm -rf *.txt';
system(command);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Call up evaluation script to compare with random learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fig4a1t
