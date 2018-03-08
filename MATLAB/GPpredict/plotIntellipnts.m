startup
close all;
clear all;
load 'Alearning_surf2D_psoTest100.mat'
%%%%% Evaluate Uncertainty over Test points
testCertainty=zeros(length(gk),length(cT)-1);
for j=2:length(cT)
    lp1=lpNR(:,j);lp2=lpD(:,j);lp3=lpND(:,j);

        for i=1:length(gk)
         [a,b]=max([exp(lp1(i)),exp(lp2(i)),exp(lp3(i))]);
    %      [c,d]=max([s1(i),s2(i),s3(i)]);
            if b==1 
                Pdist(i)=exp(lp1(i))-max([exp(lp2(i)),exp(lp3(i))]); 
            elseif b==2  
                Pdist(i)=exp(lp2(i))-max([exp(lp1(i)),exp(lp3(i))]);
            elseif b==3 
                Pdist(i)=exp(lp3(i))-max([exp(lp1(i)),exp(lp2(i))]);
            end

        end
        Pdist=Pdist';
        testCertainty(:,j-1)=Pdist;
end

%     title(Tit)
%     fname = '/home/sanosh/Dropbox/Ozone pulses_segments_posterior/Results/New_Model/Correlation plots';
%     saveas(gcf,fullfile(fname,Tit),'jpg')
    XX=linspace(0,1,100);
    Ytrue=exp(0.15*XX)-0.85;
    YY=linspace(0,1,100);
    Xtrue=exp(-0.15*YY)-0.75;
    Xtrue=Xtrue';
    XX=XX';
    Ytrue=Ytrue';
    YY=YY';
    
    count=CScale;
for i=1:length(cT)-1
    figure
    plot3(gk(:,1),gk(:,2),testCertainty(:,i),'DisplayName','Test Points','MarkerSize',2,'Marker','*',...
    'LineWidth',1,...
    'LineStyle','none',...
    'Color',[0.952941179275513 0.87058824300766 0.733333349227905])
    hold on
    plot3(Gktrain(count:count+AScale-1,1),Gktrain(count:count+AScale-1,2),ones(AScale,1),'MarkerFaceColor',[0 1 0],'MarkerSize',14,...
    'Marker','hexagram',...
    'LineWidth',3,...
    'LineStyle','none','DisplayName','Swarm Points')
    plot3(XX,Ytrue,0.01+ones(100,1),'MarkerSize',12,'LineWidth',8,'Color',[0 0 0],'DisplayName','True Boundary--Y')
    plot3(Xtrue,YY,0.01+ones(100,1),'MarkerSize',12,'LineWidth',8,'DisplayName','True Boundary--X')
    legend('show')
    Tit=strcat(num2str(AScale),'--','Intelligent Points Location with Certainty for PSO iter:-->',num2str(i));
    title(Tit)
    fname = '/home/sanosh/work_oxford/Arcus-GP/Figure';
    zlabel('Certainty');
    saveas(gcf,fullfile(fname,strcat('intellPnts-Swarm-100','--',num2str(i))),'fig')
end
% close all







