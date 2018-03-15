%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%            UQ for quinidine block 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
startup
load('./data/drugBlock/DrugBlockFITC.mat')
samples=dlmread('./data/drugBlock/Quinidine_hERG_hill_pic50_samples.txt');
conc=[0.3,3];
R=zeros(length(samples),2);
APD_GP={};
APD_Chaste={};
PredVar={};


for j=1:length(conc)
    
    for i=1:length(samples)

        pic50=samples(i,2);
        Hill =samples(i,1);
        ic50 =10^(6-pic50);

        R(i,j)=1 - (1/(1 + (ic50/conc(j))^Hill));
    end
    %%%%%%%%%% Predicted Class Labels %%%%%%%%%%%%%%%%%%
        R_blocked=ones(length(samples),4);
        y_blocked=R_blocked;
        R_blocked(:,2)=R(:,j)';
        
        gpoptions.classHyperParams.UQ=1;
        [y_blocked_class, R_blocked_AP] = boundaryDetector(R_train_class, y_train_class, R_blocked, gpoptions.classHyperParams, y_blocked);

        gpoptions.surfHyperParams.minimize=0;
        [APD_GP{j},UnCert, PredVar{j}]= surfaceGP(R_train_surf, y_train_surf, R_blocked_AP, gpoptions.surfHyperParams );

        APDUQ=EvaluateAPD(R_blocked,gpoptions.pacing); 
        [ ~, label ] = labelFinder( R_blocked, APDUQ );
        Cord=find(label(:,2)==1);
        R_true= R_blocked(Cord,:);
        APD_Chaste{j}= APDUQ(Cord);
        

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Plot UQ results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
for k=1:length(conc)
    clear pdf
    for i=1:length(APD_GP{k})
        support=linspace(0,1000,1000);
        for j=1:length(support)
            pdf(j,i)=normpdf(support(j),APD_GP{k}(i),sqrt(PredVar{k}(i)));%-exp(2*gpoptions.surfHyperParams.hyp.lik)
        end
    end
    PDF=sum(pdf,2);

    subplot1 = subplot(1,2,k,'Parent',figure1);
    hold(subplot1,'on');
    histogram(APD_Chaste{k},'Parent',subplot1,'FaceColor',[0 0 1],'Normalization','pdf',...
        'NumBins',50')
    plot(support,PDF/length(APD_GP{k}),'r','LineWidth',4)
    xlabel('APD90 (ms)')
    ylabel('Frequency');
    title(strcat(num2str(conc(k)),'\muM of quinidine'));
    box(subplot1,'on');
    set(subplot1,'CLim',[1 2],'FontSize',30);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Plot the map through a slice on linear grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=3;

R_slice=ones(1000,4);
y_slice=R_slice;
R_slice(:,2)=linspace(0,1,1000);

gpoptions.classHyperParams.UQ=1;
[y_slice_class, R_slice_AP] = boundaryDetectorNormProb(R_train_class, y_train_class, R_slice, gpoptions.classHyperParams, y_slice );

gpoptions.surfHyperParams.minimize=0;
[APD_GP{k},UnCert, PredVar{k}]= surfaceGP(R_train_surf, y_train_surf, R_slice_AP, gpoptions.surfHyperParams );

APDslice=EvaluateAPD(R_slice,gpoptions.pacing); 
[ ~, label ] = labelFinder( R_slice, APDslice );
Cord=find(label(:,2)==1);
R_true= R_slice(Cord,:);
APD_Chaste{k}= APDslice(Cord);


probaDep=dlmread('probaDep.txt');
probaNDep=dlmread('probaNDep.txt');
probaNRep=dlmread('probaNRep.txt');
certainty=dlmread('certainty.txt');

figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

f = [APD_GP{k}+2*sqrt(PredVar{k}); flipdim(APD_GP{k}-2*sqrt(PredVar{k}),1)]; 
h(1)=fill([R_slice_AP(:,2); flipdim(R_slice_AP(:,2),1)], f, [7 7 7]/8,'Parent',axes1,'DisplayName','Variance of Surface GP');
h(2)=line(R_true(:,2),APD_Chaste{k},'Parent',axes1,'DisplayName','True surface (simulator)',...
    'LineWidth',3,...
    'Color',[0 0 1]);

h(3)=line(R_slice_AP(:,2),APD_GP{k},'Parent',axes1,'DisplayName','GP surface','LineWidth',3,...
    'Color',[1 0 0]);

line([min(R_slice_AP(:,2)) min(R_slice_AP(:,2))],[0 1000],'Color','k','Parent',axes1,'LineWidth',2);
line([0.05405 0.05405],[0 1000],'Color','k','Parent',axes1,'LineWidth',2);

xlabel('R_{Kr}');
ylabel('APD_{90} (ms)');
box(axes1,'on');
set(axes1,'FontSize',28,'YColor',[0 0 0]);

axes2 = axes('Parent',figure1,...
    'ColorOrder',[0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741],...
    'Position',[0.13 0.11 0.775 0.815]);

h(4)=line(R_slice(:,2),probaDep,'Parent',axes2,'DisplayName','p(Surface)','LineWidth',3,...
    'LineStyle','-.',...
    'Color',[0.929 0.694 0.125]);

h(5)=line(R_slice(:,2),probaNRep,'Parent',axes2,'DisplayName','p(No-Repolarisation)',...
    'LineWidth',3,...
    'LineStyle','-.',...
    'Color',[0.494 0.184 0.556]);

h(6)=line(R_slice(:,2),probaNDep,'Parent',axes2,'DisplayName','p(No-Depolarisation)',...
    'LineWidth',3,...
    'LineStyle','-.',...
    'Color',[0.466 0.674 0.188]);
ylabel('Classifier probability \pi^k');

set(axes2,'Color','none','FontSize',28,'HitTest','off','YAxisLocation',...
    'right','YColor',[0 0 0]);

legend1=legend(h, 'Variance of Surface GP', 'True surface (simulator)', 'Surface GP prediction','p(Surface)','p(No-Repolarisation)', 'p(No-Depolarisation)');

set(legend1,...
    'Position',[0.615419305596157 0.578166158659165 0.252291098502126 0.313543590190017]);

annotation(figure1,'textarrow',[0.282344800161158 0.169076191746918],...
    [0.85460900681552 0.85460900681552],...
    'String',{'Classifier estimated boundary'},...
    'LineWidth',2,...
    'HeadWidth',15,...
    'HeadLength',20,...
    'FontSize',28);

annotation(figure1,'textarrow',[0.282749108245972 0.172062082015807],...
    [0.186694041607659 0.186694041607659],'String',{'True surface boundary'},...
    'LineWidth',2,...
    'HeadWidth',15,...
    'HeadLength',20,...
    'FontSize',28);











