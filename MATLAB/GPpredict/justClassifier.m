function [ Labels ] = justClassifier(x, y, xp, HyperParams )

[ x_train,y_train ] = labelFinder( x, y);
HyperParams.hyp=HyperParams.hyp1;
[s1, lpNR ] = classifierGP( x_train, y_train(:,1), xp, HyperParams);
HyperParams.hyp=HyperParams.hyp2;
[s2, lpD ] = classifierGP( x_train, y_train(:,2), xp, HyperParams);
HyperParams.hyp=HyperParams.hyp3;
[s3, lpND ] = classifierGP( x_train, y_train(:,3), xp, HyperParams);


j=1;
k=1;
l=1;
for i=1:length(xp)
 [a,b]=max([exp(lpNR(i)),exp(lpD(i)),exp(lpND(i))]);% % 
 [c,d]=min([s1(i),s2(i),s3(i)]);

    if b==1 %&& d==1%%&& APDtrue(i)==1500
        Labels(i)=0;
        j=j+1;
    elseif b==2 && exp(lpD(i))>0.7 %APDtrue(i)~=10 && APDtrue(i)~=1500 
         Labels(i)=1;
        k=k+1;
    elseif b==3 %&& d==3%%&& APDtrue(i)==10
         Labels(i)=0;
        l=l+1;
    end

end


end

