close all
clear all

test_output_dir = '/export/testoutput/TestApdSurface2D/';

d = importdata([test_output_dir 'APDs.dat']);

figure(1)
plot3(d.data(:,2), d.data(:,3), d.data(:,4), '.')
xlabel('gNa scaling factor')
ylabel('gKr scaling factor')
zlabel('APD (ms)')

