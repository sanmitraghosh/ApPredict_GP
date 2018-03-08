function [Entropy] = surfaceCertainty( x, y, xstar, HyperParams  )

           dim=size(x,2);
           Ind=HyperParams.NumInducingSurf;
           sparse=nthroot(Ind,dim);
           switch dim
               case 4
                [u1,u2,u3,u4] = ndgrid(linspace(0,1,sparse)); 
                u = [u1(:),u2(:),u3(:), u4(:)]; 
                clear u1; clear u2;clear u3;
               case 3
                [u1,u2,u3] = ndgrid(linspace(0,1,sparse)); 
                u = [u1(:),u2(:),u3(:)]; 
                clear u1; clear u2;clear u3;
               case 2
                [u1,u2] = ndgrid(linspace(0,1,sparse)); 
                u = [u1(:),u2(:)]; 
                clear u1; clear u2;
            end

    
    %%%%%%%%%%%% Prepare GP %%%%%%%
            surfmeanfunc = @meanConst; 
            covfunc = HyperParams.covfunction;%@covRQiso;  
            covfuncF = {@covFITC, {covfunc},u};
            surflikfunc = @likGauss;

            if length(x)<HyperParams.sparseMarginSurf
                inffunc = @infExact;
                surfcov=covfunc;
            else
                inffunc = @infFITC; 
                surfcov=covfuncF;

            end
    [PredMean,PredVar] = gp(HyperParams.hyp, inffunc, surfmeanfunc, surfcov, surflikfunc, x, y, xstar);
    Entropy=0.5*log(PredVar) + 0.5*(log(2*pi) +1);
%     DistCert=pdist2(UnCert,UnCert,'seuclidean');
%     for i=1:length(UnCert)
%         smallest=sort(DistCert(:,i));
%         UnCert(i)=UnCert(i) + 1.5*smallest(2);
%     end
%     UnCert=UnCert + 1*Predmean;
%     UnCert=UnCert';
    
end



