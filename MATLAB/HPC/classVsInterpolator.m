
%%%%%%%%%%%%% This script runs the iterative active learning for
%%%%%%%%%%%%% accumulating training points for the O'hara model. NB: the
%%%%%%%%%%%%% dataset contains pretrained hyperparameters of a GP
%%%%%%%%%%%%% classifier and the APD90 dataset 0f 100K
% rsync -avz /home/sanosh/work_oxford/Arcus-GP coml0640@arcus-b.arc.ox.ac.uk:/data/coml-cardiac/coml0640


%%%%%%%%%%%%%%%%%%%%%%%
    % Set random seed
%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
addpath(genpath('/data/coml-cardiac/coml0640/Backup/ApPredict_GPmat'))
load('Alearning_4D_100k_Train.mat');
TestData=load('Alearning_4D_100k_Test.mat');
% tic;
a=pwd;
if strcmp(a(end-1),'a')
	num=str2num(a(end));
else 
num=str2num(a(end-1))*10 + str2num(a(end));
end
n1=num*500;
ns=50;
Telapsed=zeros(1000,1);
STOPCLASS=n1 + 4*ns;
STOPSURF=n1 + 2*4*ns;
gpoptions.pacing=100;
gpoptions.NumInducingClass=300;
gpoptions.sparseMargin=5000;
gpoptions.NumInducingSurf=1000;
gpoptions.sparseMarginSurf=5000;
gpoptions.classHyperParams.minimize=0;
gpoptions.surfHyperParams.minimize=0;
gpoptions.covarianceKernels={'covMaterniso',5};
gpoptions.covarianceKernelsParams=[0.1;1.20];
gpoptions.likelihoodParams=0.015;
tic;
R_train=gk;
Y_train=APDtrue;

R_test=TestData.gk;
Y_test=TestData.APDtrue;


nu = fix(n1); cu = randperm(length(R_train)); cu = cu(1:nu); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R_train = R_train(cu,:);
y_train=Y_train(cu,:); %%% Start with random n1 points
gpoptions.LearningMode='classifier';
outparam= learnGPhyp( R_train, y_train, gpoptions );
trainTime=toc;
gpoptions.classHyperParams=outparam;
gpoptions.classHyperParams.minimize=0;
tic;
[Yp, RepG, yRepG ] = build_multi_domains( R_train, y_train, R_test, Y_test, gpoptions.classHyperParams );

%%%%%%%%%% True Class Labels %%%%%%%%%%%%%%%%%%
for i=1:length(R_test)
    if Y_test(i)==1000
        Yt(i)=1;
    elseif Y_test(i)==0
        Yt(i)=-1;
    else
        Yt(i)=0;
    end
end
MisClassP=0;%%%%build confusion
Yt=Yt+1;Yp=Yp+1;
    for i=1:length(R_test)
        if Yt(i)~=Yp(i)
            MisClassP=MisClassP+1;
        end
    end
ClassifierError=MisClassP; 
[Confusion,Confusion_order] = confusionmat(Yt,Yp);
ClassifierPerformance = classperf(Yt, Yp);
predTime=toc;
totalTime=trainTime+predTime;
data=strcat('C',num2str(n1),'.mat');
save (data)
exit;


