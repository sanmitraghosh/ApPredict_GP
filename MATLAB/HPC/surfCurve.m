% rsync -avz /home/sanosh/work_oxford/Arcus-GP coml0640@arcus-b.arc.ox.ac.uk:/data/coml-cardiac/coml0640


%%%%%%%%%%%%%%%%%%%%%%%
    % Collect all learning curves for surface GP
%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
addpath(genpath('/data/coml-cardiac/coml0640/Backup/ApPredict_GPmat'))
startup

for i=1:99
 try
    file=strcat(num2str(i*500),'.mat');
    A=load(file);
    Error(i)=A.SurfaceError;
    totalTime(i)=A.totalTime;
    predTime(i)=A.predTime;
    trainTime(i)=A.TrainTime;
    n1(i)=A.n1;
    %clear A
 catch
	warning('Problem with hyperparameter.');
	Error(i)=0;
    	totalTime(i)=0;
    	predTime(i)=0;
    	trainTime(i)=0;
    	n1(i)=0;
 end
end


save ('surf1lCurve.mat');
exit;


