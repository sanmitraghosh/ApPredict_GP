function [Yp,RepG,yRepG] = build_multi_domains_silly( x, y, xp, APDtrue, HyperParams )
 
disp('Using Correct multidomain')
[ x_train,y_train ] = labelFinder( x, y);
HyperParams.hyp=HyperParams.hyp1;
[s1, lpNR ] = pred_class_prob( x_train, y_train(:,1), xp, HyperParams);
HyperParams.hyp=HyperParams.hyp2;
[s2, lpD ] = pred_class_prob( x_train, y_train(:,2), xp, HyperParams);
HyperParams.hyp=HyperParams.hyp3;
[s3, lpND ] = pred_class_prob( x_train, y_train(:,3), xp, HyperParams);

lp1=exp(lpNR);lp2=exp(lpD);lp3=exp(lpND);
for i=1:length(xp)
%     minim=min([exp(lp1(i)),exp(lp2(i)),exp(lp3(i))]);
%     maxim=max([exp(lp1(i)),exp(lp2(i)),exp(lp3(i))]);
%     lp1(i)=exp(lp1(i))-minim/maxim-minim;
%     lp2(i)=exp(lp2(i))-minim/maxim-minim;
%     lp3(i)=exp(lp3(i))-minim/maxim-minim;
      Tot=sum(lp1(i)+lp2(i)+lp3(i));
      lp1(i)=lp1(i)/Tot;
      lp2(i)=lp2(i)/Tot;
      lp3(i)=lp3(i)/Tot;

end

    
for i=1:length(xp)
 [a,b]=max([lp1(i),lp2(i),lp3(i)]);
%      [c,d]=max([s1(i),s2(i),s3(i)]);
    if b==1 
        Pdist(i)=lp1(i)-max([lp2(i),lp3(i)]); 
    elseif b==2  
        Pdist(i)=lp2(i)-max([lp1(i),lp3(i)]);
    elseif b==3 
        Pdist(i)=lp3(i)-max([lp1(i),lp2(i)]);
    end

end
Pdist=Pdist';


%%%%%% Find seperate domains
j=1;
k=1;
l=1;
for i=1:length(xp)
 [a,b]=max([lp1(i),lp2(i),lp3(i)]);
%  [c,d]=min([s1(i),s2(i),s3(i)]);
    if b==1 
        Yp(i)=1;        
    elseif b==2 %&& Pdist(i)>0.75
        if HyperParams.UQ==1
            RepG(k,:)=xp(i,:);
            k=k+1;
        else    
            if APDtrue(i)~=0 && APDtrue(i)~=1000 
                RepG(k,:)=xp(i,:);
                yRepG(k)=APDtrue(i);
                k=k+1;
            end
        end
%         yRepG(k)=APDtrue(i);
%         RepG(k,:)=xp(i,:);
%         k=k+1;
        Yp(i)=0;
%     elseif b==2 && Pdist(i)<=0.9
%         [c,d]=max([exp(lpNR(i)),exp(lpND(i))]);
%         if d==1
%             Yp(i)=1;
%         else
%             Yp(i)=-1;
%         end
        
    elseif b==3 
        Yp(i)=-1;
    end
end

dlmwrite('certainty.txt',Pdist);
dlmwrite('probaDep.txt',lp2);
dlmwrite('probaNRep.txt',lp1);
dlmwrite('probaNDep.txt',lp3);

end

