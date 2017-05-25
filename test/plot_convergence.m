close all
clear all

d = importdata('/export/testoutput/InterpolationError/InterpolationError.dat');
data = d.data;

num_test_points = 10000;

for i=1:size(data,1)
    assert(sum(data(i,3:end))==num_test_points); % Check nothing funny is going on!
    misclassification_rate(i) = (num_test_points - data(i,3) -data(i,7) - data(i,11))./num_test_points;
end


figure
subplot(2,2,1)
plot(data(:,1),data(:,2),'r-')
ylabel('L1 Error in APD90 (ms)')
xlabel('Number of Training Points')

subplot(2,2,2)
loglog(data(:,1),data(:,2),'r-')
ylabel('L1 Error in APD90 (ms)')
xlabel('Number of Training Points')

subplot(2,2,3)
plot(data(:,1),100.0.*misclassification_rate,'b-')
ylabel('Misclassification Rate (%)')
xlabel('Number of Training Points')

subplot(2,2,4)
loglog(data(:,1),100.0.*misclassification_rate,'b-')
ylabel('Misclassification Rate (%)')
xlabel('Number of Training Points')
