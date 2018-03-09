function [x, y] = labelFinder(Gk, APDkn)
%%%%%% A helper function that finds the labels on the basis of simulator error codes %%%%


x=Gk;
for i=1:length(x)
    if APDkn(i)==1000
        y1(i)=1;
    else
        y1(i)=-1;
    end
end
y1=y1';

for i=1:length(x)
    if APDkn(i)==0 
        y2(i)=-1;
    elseif APDkn(i)==1000
        y2(i)=-1;
    else
        y2(i)=1;
    end
end
y2=y2';

for i=1:length(x)
    if APDkn(i)==0
        y3(i)=1;
    else
        y3(i)=-1;
    end
end
y3=y3';
y=[y1 y2 y3];

end

