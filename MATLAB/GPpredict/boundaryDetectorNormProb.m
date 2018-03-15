function [y_star_class, R_star_AP, y_star_AP] = boundaryDetectorNormProb(R, y, R_star, HyperParams, y_true)
%%%%%% This function is for plotting Normalised probabilities and certainty %%%%

[ R_train,y_train ] = labelFinder( R, y);
HyperParams.hyp=HyperParams.hyp1;
[s1, lpNR ] = classifierGP( R_train, y_train(:,1), R_star, HyperParams);
HyperParams.hyp=HyperParams.hyp2;
[s2, lpD ] = classifierGP( R_train, y_train(:,2), R_star, HyperParams);
HyperParams.hyp=HyperParams.hyp3;
[s3, lpND ] = classifierGP( R_train, y_train(:,3), R_star, HyperParams);

lp1=exp(lpNR);lp2=exp(lpD);lp3=exp(lpND);
for i=1:length(R_star)
      Tot=sum(lp1(i)+lp2(i)+lp3(i));
      lp1(i)=lp1(i)/Tot;
      lp2(i)=lp2(i)/Tot;
      lp3(i)=lp3(i)/Tot;

end

    
for i=1:length(R_star)
 [a,b]=max([lp1(i),lp2(i),lp3(i)]);
    if b==1 
        Pdist(i)=lp1(i)-max([lp2(i),lp3(i)]); 
    elseif b==2  
        Pdist(i)=lp2(i)-max([lp1(i),lp3(i)]);
    elseif b==3 
        Pdist(i)=lp3(i)-max([lp1(i),lp2(i)]);
    end

end
Pdist=Pdist';


%%%%%% Perform OVR classification but on Normalise probabilities for ease
%%%%%% of visualisation
j=1;
k=1;
l=1;
for i=1:length(R_star)
 [a,b]=max([exp(lpNR(i)),exp(lpD(i)),exp(lpND(i))]);
    if b==1 
        y_star_class(i)=1;        
    elseif b==2 
        if HyperParams.UQ==1 || nargin < 5
            R_star_AP(k,:)=R_star(i,:);
            k=k+1;
        else    
            if y_true(i)~=0 && y_true(i)~=1000 
                R_star_AP(k,:)=R_star(i,:);
                y_star_AP(k)=y_true(i);
                k=k+1;
            end
        end
        y_star_class(i)=0;
    elseif b==3 
        y_star_class(i)=-1;
    end
end

dlmwrite('certainty.txt',Pdist);
dlmwrite('probaDep.txt',lp2);
dlmwrite('probaNRep.txt',lp1);
dlmwrite('probaNDep.txt',lp3);

end

