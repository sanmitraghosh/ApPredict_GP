% close all
% clear all
function [APD]= EvaluateAPD(gk,Init_Pace)
% tic
parfor i=1:length(gk)
gNa = gk(i,1);
gKr = gk(i,2);
gKs = gk(i,3);
gCaL = gk(i,4);
 
[status, cmdout] = system(['./matlab_wrapper.sh --gNa ' num2str(gNa)...
                                              ' --gKr ' num2str(gKr)...
                                              ' --gKs ' num2str(gKs)...
                                              ' --gCaL ' num2str(gCaL)]);

% Check it was a successful call
assert(status==0)

% Find line breaks in the output
newline_indices = find(double(cmdout)==10);

% First line is the APD90
apd(i) = str2num(cmdout(1:(newline_indices(1)-1)))
end
% toc
APD=apd';

% plot3(gk(1:10000,1),gk(1:10000,2),APDtrue(1:10000),'*','MarkerSize',5)