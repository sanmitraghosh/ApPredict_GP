
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script plots the GP vs Interpolator curves 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all

d = importdata('./data/GPVsLUT/InterpolationErrorClass.dat');
data = d.data;
surf=load('./data/GPVsLUT/Fig1lsurfCurve.mat');
class=load('./data/GPVsLUT/Fig1lclassCurve.mat');
num_test_points = 100000;%86027;
time=795.9423;
classtestTime=time*(100000/500);%86027
surftestTime=time*(86027/500);%

for i=1:size(data,1)
    assert(sum(data(i,3:end))==num_test_points); % Check nothing funny is going on!
    misclassification_rate(i) = (num_test_points - data(i,3) -data(i,7) - data(i,11))./num_test_points;
end
for i=1:length(surf.n1)
    surfTime=time*(surf.n1/500);
    classTime=time*(class.n1/500);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Learning curve of Surface GP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d = importdata('./data/GPVsLUT/InterpolationErrorSurf.dat');
data = d.data;
fn=10;
font_size=fn;
f_width =2.5;f_height=1.77;
font_rate=10/font_size;

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
plot(data(:,1),data(:,2),'DisplayName','Interpolation','LineWidth',2,'Color',[0 0 1])
plot(surf.n1,surf.Error,'DisplayName','GP','LineWidth',2,'Color',[1 0 0])

xlabel('Number of Training Points');
ylabel('Mean Absolute Error in APD90 (ms)');
title('Interpolator Vs Surface GP Learning Curve','HorizontalAlignment','center');

xlim(axes1,[500 49500]);
ylim(axes1,[0 70]);


box(axes1,'on');
grid(axes1,'on');
set(axes1,'FontSize',fn,'XMinorTick','on','YMinorTick','on');
legend1 = legend(axes1,'show');
% set(legend1,...
%     'Position',[0.738634324745884 0.805520286774449 0.154716977420843 0.0868892987698189]);
line('XData',[10000 10000], 'YData', [0 70],'LineWidth',2)
annotation(figure1,'textbox',...
    [0.146091644204852 0.778293135435993 0.127223719676551 0.0400467380204867],...
    'String',{'True'},...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

% Create textbox
annotation(figure1,'textbox',...
    [0.331106319257266 0.782931354359926 0.131075471698112 0.0354085190965538],...
    'String','FITC',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Learning curve log axes of Surface GP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
loglog(data(:,1),data(:,2),'LineWidth',2,'Color',[0 0 1])
loglog(surf.n1,surf.Error,'LineWidth',2,'Color',[1 0 0])
xlabel('Number of Training Points');
ylabel('Mean Absolute Error in APD90 (ms)');
xlim(axes1,[500 49500])
box(axes1,'on');
grid(axes1,'on');
set(axes1,'FontSize',fn,'XMinorGrid','on','XMinorTick','on','XScale','log',...
    'YMinorGrid','on','YMinorTick','on','YScale','log','ZMinorGrid','on');

annotation(figure1,'textbox',...
    [0.694261455525612 0.775794869078929 0.131075471698112 0.0354085190965538],...
    'String','FITC',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

annotation(figure1,'textbox',...
    [0.389757412398924 0.770264589494871 0.127223719676551 0.0400467380204867],...
    'String',{'True'},...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
annotation(figure1,'line',[0.635135135135135 0.635040431266846],...
    [0.175097276264591 0.924174843889385],'LineWidth',2);

set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Learning curve of classifier GP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d = importdata('./data/GPVsLUT/InterpolationErrorClass.dat');
data = d.data;
fn=10
figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');

plot(data(:,1),100.0.*misclassification_rate,'b','LineWidth',2)
plot(class.n1,100*(class.Error/num_test_points),'r','LineWidth',2)
line('XData',[5000 5000], 'YData', [0 70],'LineWidth',2)

xlabel('Number of Training Points');
ylabel('Misclassification Rate (%)');
title('Interpolator Vs Boundary (Classifier) GP Learning Curve');

xlim(axes1,[500 49500]);
ylim(axes1,[0 15]);
box(axes1,'on');
grid(axes1,'on');

set(axes1,'FontSize',fn,'XMinorTick','on','YMinorTick','on');

annotation(figure1,'textbox',...
    [0.135309973045826 0.661433188959638 0.047978436657678 0.0400467380204871],...
    'String','True',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

annotation(figure1,'textbox',...
    [0.274854447439358 0.666071407883567 0.131075471698113 0.0354085190965538],...
    'String','FITC',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
% set(gcf,'Position',[100   200   627   435])%430   313])
set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Learning curve log axes of Classifier GP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
loglog(data(:,1),100.0.*misclassification_rate,'LineWidth',2,'Color',[0 0 1])
loglog(class.n1,100*(class.Error/num_test_points),'LineWidth',2,'Color',[1 0 0])
xlabel('Number of Training Points');
ylabel('Misclassification Rate (%)');
xlim(axes1,[500 49500])
ylim(axes1,[1 15]);
box(axes1,'on');
grid(axes1,'on');
set(axes1,'FontSize',fn,'XMinorTick','on','XScale','log','YMinorTick','on',...
    'YScale','log');

annotation(figure1,'textbox',...
    [0.421563342318069 0.648510840621754 0.047978436657678 0.040046738020487],...
    'String','True',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

annotation(figure1,'textbox',...
    [0.561107816711601 0.653149059545683 0.131075471698113 0.0354085190965538],...
    'String','FITC',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

annotation(figure1,'line',[0.518059299191379 0.518059299191379],...
    [0.1808926376357664 0.926149443531301],'LineWidth',2);

set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Training Time of Surface GP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');
fn=11;
font_size=fn;
f_width =5;f_height=3;
font_rate=10/font_size;

loglog(surf.n1,surfTime,'LineWidth',2,'DisplayName','Simulator (ODE Chaste)','Color',[0 0 1])

loglog(surf.n1,surf.trainTime,'LineWidth',2,'DisplayName','GP','Color',[1 0 0])
loglog(surf.n1,surfTime+surf.trainTime,'LineWidth',2,'LineStyle','--','DisplayName','Totaltime(GP + SImulator)','Color','m')

line('XData',[500 49500],'YData',[surftestTime surftestTime],'Parent',axes1,...
    'DisplayName','Simulator test set prediction',...
    'LineWidth',2,...
    'LineStyle','--',...
    'Color',[0 1 0]);
xlabel('Number of Training Points');
ylabel('Training time surface GP (s)');
box(axes1,'on');
grid(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',fn,'XMinorGrid','on','XMinorTick','on','XScale','log',...
    'YMinorGrid','on','YMinorTick','on','YScale','log','ZMinorGrid','on');
xlim(axes1,[500 49500]);
ylim(axes1,[0 1000000]);

% Create legend
legend1 = legend(axes1,'show');

% Create line
annotation(figure1,'line',[0.518624053394943 0.518624053394943],...
    [0.115799497594694 0.92616612212061],'LineWidth',3);

% Create textbox
annotation(figure1,'textbox',...
    [0.546552560646907 0.877306903622699 0.188757412398915 0.0354085190965538],...
    'String','FITC',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.207008086253369 0.87177662403864 0.195687331536392 0.0400467380204867],...
    'String',{'True'},...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor','none');

set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prediction Time of Surface GP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

loglog(surf.n1,surfTime,'LineWidth',2,'DisplayName','Simulator (ODE Chaste)','Color',[0 0 1])

loglog(surf.n1,surf.predTime,'LineWidth',2,'DisplayName','GP','Color',[1 0 0])

line('XData',[500 49500],'YData',[surftestTime surftestTime],'Parent',axes1,...
    'DisplayName','Simulator test set prediction',...
    'LineWidth',2,...
    'LineStyle','--',...
    'Color',[0 1 0]);
xlabel('Number of Training Points');
ylabel('Prediction time surface GP (s)');
box(axes1,'on');
grid(axes1,'on');
set(axes1,'FontSize',fn,'XMinorGrid','on','XMinorTick','on','XScale','log',...
    'YMinorGrid','on','YMinorTick','on','YScale','log','ZMinorGrid','on');
xlim(axes1,[500 49500]);
ylim(axes1,[0 1000000]);
% Create legend
% legend1 = legend(axes1,'show');
annotation(figure1,'textbox',...
    [0.343935309973048 0.75067980318395 0.127223719676551 0.0400467380204867],...
    'String',{'True'},...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.709894878706208 0.756245665892669 0.131075471698113 0.0354085190965538],...
    'String','FITC Covariance',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create line
annotation(figure1,'line',[0.635823429541596 0.635823429541596],...
    [0.11339759803991 0.924830168014464],'LineWidth',3);

set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Training Time of Classifier GP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

loglog(surf.n1,classTime,'LineWidth',2,'DisplayName','Simulator (ODE Chaste)','Color',[0 0 1])

loglog(surf.n1,class.trainTime,'LineWidth',2,'DisplayName','GP','Color',[1 0 0])
loglog(surf.n1,classTime+class.trainTime,'LineWidth',2,'LineStyle','--','DisplayName','Totaltime(GP + SImulator)','Color','m')
line('XData',[500 49500],'YData',[classtestTime classtestTime],'Parent',axes1,...
    'DisplayName','Simulator test set prediction',...
    'LineWidth',2,...
    'LineStyle','--',...
    'Color',[0 1 0]);
xlabel('Number of Training Points');
ylabel('Training time classifier GP (s)');
box(axes1,'on');
grid(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',fn,'XMinorGrid','on','XMinorTick','on','XScale','log',...
    'YMinorGrid','on','YMinorTick','on','YScale','log','ZMinorGrid','on');
xlim(axes1,[500 49500]);
ylim(axes1,[10 1000000]);

legend1 = legend(axes1,'show');
% set(legend1,...
%     'Position',[0.527313574736229 0.162469792136663 0.368733143549403 0.150896718012527],...
%     'FontSize',33);
annotation(figure1,'line',[0.518624053394943 0.518624053394943],...
    [0.115799497594694 0.92616612212061],'LineWidth',3);
annotation(figure1,'textbox',...
    [0.546552560646907 0.877306903622699 0.188757412398915 0.0354085190965538],...
    'String','FITC',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(figure1,'textbox',...
    [0.207008086253369 0.87177662403864 0.195687331536392 0.0400467380204867],...
    'String',{'True'},...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor','none');

set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prediction Time of Classifier GP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

loglog(class.n1,classTime,'LineWidth',2,'DisplayName','Simulator (ODE Chaste)','Color',[0 0 1])

loglog(class.n1,class.predTime,'LineWidth',2,'DisplayName','GP','Color',[1 0 0])

line('XData',[500 49500],'YData',[classtestTime classtestTime],'Parent',axes1,...
    'DisplayName','Simulator test set prediction',...
    'LineWidth',2,...
    'LineStyle','--',...
    'Color',[0 1 0]);
xlabel('Number of Training Points');
ylabel('Prediction time classifier GP (s)');
box(axes1,'on');
grid(axes1,'on');

set(axes1,'FontSize',fn,'XMinorGrid','on','XMinorTick','on','XScale','log',...
    'YMinorGrid','on','YScale','log','ZMinorGrid','on');
xlim(axes1,[500 49500]);
ylim(axes1,[10 1000000]);
annotation(figure1,'line',[0.519137466307286 0.519137466307286],...
    [0.108723461195361 0.924174843889385],'LineWidth',3);

annotation(figure1,'textbox',...
    [0.156873315363882 0.843123933540656 0.201078167115902 0.0400467380204867],...
    'String',{'True'},...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

annotation(figure1,'textbox',...
    [0.533614555256068 0.846834508679802 0.191452830188676 0.0354085190965538],...
    'String','FITC',...
    'FontSize',fn,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])


