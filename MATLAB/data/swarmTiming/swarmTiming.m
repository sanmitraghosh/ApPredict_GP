%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Error Vs Timing Curves FITC SwarmSizes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
startup
time=39.428151;
BBData=load('resultBBfitc.mat');
BBtimeTrue=BBData.ActiveData.tintelli(1:5)-time;
BBErrorRate=BBData.ClassifierErrorActive(2:end);
BBErrorRate=BBErrorRate;

BMData=load('resultBMfitc.mat');
BMtimeTrue=BMData.ActiveData.tintelli(1:10)-time;
BMErrorRate=BMData.ClassifierErrorActive(2:end);
BMErrorRate=BMErrorRate;


BSData=load('resultBSfitc.mat');
BStimeTrue=BSData.ActiveData.tintelli(1:50)-time;
BSErrorRate=BSData.ClassifierErrorActive(2:end);
BSErrorRate=BSErrorRate;

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
plot(cumsum(BBtimeTrue),BBErrorRate,'g','MarkerSize',8,'Marker','diamond','LineWidth',4)
plot(cumsum(BMtimeTrue),BMErrorRate,'r','MarkerSize',8,'Marker','diamond','LineWidth',4)
plot(cumsum(BStimeTrue),BSErrorRate,'b','MarkerSize',8,'Marker','diamond','LineWidth',4)
line('XData',[3600 3600], 'YData', [1.5 2.5],'LineWidth',3)
Ulim=cumsum(BStimeTrue);
xlim([BMtimeTrue(1) Ulim(end)])
xlabel('Cummulative Training Time (h)')
ylabel('Normalised Misclassification Rate')
grid on;
grid minor;
set(axes1,'FontSize',30,'XMinorGrid','on','XTickLabel',...
    {num2str(10000/3600),num2str(20000/3600),...,
    num2str(30000/3600),num2str(40000/3600),num2str(50000/3600),num2str(60000/3600)},'YMinorGrid','on')
legend('Swarm = 1000','Swarm = 500','Swarm = 100')
title('Timing Comparison of Swarms with FITC covarince')


