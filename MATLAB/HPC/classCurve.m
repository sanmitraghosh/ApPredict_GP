
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
startup
% confusion={};
for i=1:99
    file=strcat('C',num2str(i*500),'.mat');
    A=load(file);
    Error(i)=A.MisClassP;
    totalTime(i)=A.totalTime;
    predTime(i)=A.predTime;
    trainTime(i)=A.trainTime;
    n1(i)=A.n1;
%     confusion{i}=A.Confusion;
    
    clear A;
end


save ('classlCurve.mat');
exit;


