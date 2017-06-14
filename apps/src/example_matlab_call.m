close all
clear all

gNa = 1.0;
gKr = 1.0;
gKs = 1.0;
gCaL = 1.0;


[status, cmdout] = system(['./matlab_wrapper.sh --gNa ' num2str(gNa)...
                                              ' --gKr ' num2str(gKr)...
                                              ' --gKs ' num2str(gKs)...
                                              ' --gCaL ' num2str(gCaL)]);

% Check it was a successful call
assert(status==0)

% Find line breaks in the output
newline_indices = find(double(cmdout)==10);

% First line is the APD90
apd = str2num(cmdout(1:(newline_indices(1)-1)))