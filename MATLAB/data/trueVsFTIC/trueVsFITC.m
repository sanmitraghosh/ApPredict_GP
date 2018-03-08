%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Error Vs Timing Curves True vs FITC 10 times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
time=39.428151;
for i=1:10
    TrueData=load(strcat('./a1t/resultTrue',num2str(i),'.mat'));
    GPtimeTrue(:,i)=TrueData.ActiveData.tintelli(1:30)-time;
    FitcData=load(strcat('./a1f/resultFitc',num2str(i),'.mat'));
    GPtimeFitc(:,i)=FitcData.ActiveData.tintelli(1:30)-time;
    FitcErrorRate(:,i)=FitcData.ClassifierErrorActive(2:end);
%     FitcErrorRate(:,i)=FitcErrorRate(:,i)/FitcErrorRate(1,i);
    TrueErrorRate(:,i)=TrueData.ClassifierErrorActive(2:end);
%     TrueErrorRate(:,i)=TrueErrorRate(:,i)/TrueErrorRate(1,i);
end
GPtimeTrue=mean(GPtimeTrue,2);
GPtimeFitc=mean(GPtimeFitc,2);
FitcErrorRate=mean(FitcErrorRate,2);
TrueErrorRate=mean(TrueErrorRate,2);

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
plot(cumsum(GPtimeTrue),TrueErrorRate,'g','MarkerSize',8,'Marker','diamond','LineWidth',3)
plot(cumsum(GPtimeFitc),FitcErrorRate,'r','MarkerSize',8,'Marker','diamond','LineWidth',3)
Ulim=cumsum(GPtimeTrue);
xlim([GPtimeTrue(1) Ulim(end)])
xlabel('Cummulative Training Time (h)')
ylabel('Normalised Misclassification Rate')
grid on;
grid minor;
set(axes1,'FontSize',33,'XMinorGrid','on','XTick',...
[5000 15000 25000 35000 45000],'XTickLabel',...
{'1.3','4.1','6.9','9.7','12.5'},'YMinorGrid','on','ZMinorGrid','on');
legend('True Covariance','FITC Covariance')
title('Classifier Active Learning Timing average of 10 runs')

pause(10)


clear all
close all
time=39.428151;
figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
GPtimeTrue=zeros(31,1);
GPtimeFitc=zeros(31,1);
for i=1:10
    TrueData=load(strcat('./a1t/resultTrue',num2str(i),'.mat'));
    GPtimeTrue(2:end)=TrueData.ActiveData.tintelli(1:30)-time;
    FitcData=load(strcat('./a1f/resultFitc',num2str(i),'.mat'));
    GPtimeFitc(2:end)=FitcData.ActiveData.tintelli(1:30)-time;
    FitcErrorRate=FitcData.ClassifierErrorActive(1:end);
    TrueErrorRate=TrueData.ClassifierErrorActive(1:end);
    plot(cumsum(GPtimeTrue),TrueErrorRate,'g','MarkerSize',8,'Marker','diamond','LineWidth',3)
    plot(cumsum(GPtimeFitc),FitcErrorRate,'r','MarkerSize',8,'Marker','diamond','LineWidth',3)
end

Ulim=cumsum(GPtimeTrue);
xlim([GPtimeTrue(1) Ulim(end)])
xlabel('Cummulative Training Time (h)')
ylabel('Misclassification Rates')
grid on;
grid minor;
set(axes1,'FontSize',33,'XMinorGrid','on','XTick',...
[5000 15000 25000 35000 45000],'XTickLabel',...
{'1.3','4.1','6.9','9.7','12.5'},'YMinorGrid','on','ZMinorGrid','on');
legend('True Covariance','FITC Covariance')
title('Classifier Active Learning Timing all 10 runs')
    
    
    
    
    
