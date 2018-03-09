%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% APD evaluate at scale on HPC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%

clear
startup
[t1,t2] = ndgrid(linspace(0,1,100)); 
gk = [t1(:),t2(:)]; 
gk(:,3)=1;gk(:,4)=1;
tic
[APDtrue]=EvaluateAPD(gk,100);
toc

save('Alearning_2D_10k_Grid.mat');
clear 
gk=unifrnd(0,1,4,50)';
scale=linspace(0,1,500)';
gk=ones(500,4);
gk(:,2)=scale;
gk(:,1)=1;gk(:,3)=1;gk(:,4)=1;
tic
[APDtrue]=EvaluateAPD(gk,100);
toc
save('Alearning_4D_100k_Test.mat');
exit;

% steps=linspace(0,100000,100000)';
% throw_chaste=[gk APDtrue];
% % % % dlmwrite('myParam.dat',throw_chaste,'Delimiter',' ','precision','%1.8e','coffset',2);
% fileID=fopen('matlab.txt','w');
% fprintf(fileID,'  %1.8e   %1.8e   %1.8e   %1.8e   %1.8e \n',throw_chaste');
% fclose(fileID);
% % exit;
% 
% plot3(gk(:,1),gk(:,2),APDtrue,'b*','MarkerSize',1);
% scp coml0640@arcus-b.arc.ox.ac.uk:/data/coml-cardiac/coml0640/Backup/ApPredict_GPmat/Fig1_bck/Fig1lCurve.mat /home/sanosh/work_oxford/ApPredict_GPmat/results/
% scp ApPredict_GP_fitc4Dinit.mat  coml0640@arcus-b.arc.ox.ac.uk:/data/coml-cardiac/coml0640/Backup/ApPredict_GPmat/


[ ~, label ] = labelFinder( gk, APDtrue );
Cord=find(label(:,3)==1);

plot3(gk(Cord,1),gk(Cord,2),APDtrue(Cord),'b*','MarkerSize',1);