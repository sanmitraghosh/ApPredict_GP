close all
clear all

test_output_dir = '/export/testoutput/TestApdProfile/';

resolution = 100;
max_GNa = 0.3;
gKr_value = 0.5;

figure(1)

for i=1:resolution+1
    file_name = [test_output_dir 'ohara_rudy_2011_' num2str(max_GNa.*(i-1.0)./resolution) '_' num2str(gKr_value) '_.dat'];
    d = importdata(file_name);
    plot3(d.data(:,1), ones(length(d.data),1).*max_GNa*(i-1.0)/resolution, d.data(:,2), '-')
    hold all
end

xlabel('Time (ms)')
ylabel('gNa scaling factor')
zlabel('Voltage (mV)')

d = importdata([test_output_dir 'APDs.dat'])

figure(2)
plot(d.data(:,2),d.data(:,end),'.-')
xlabel('gNa scaling factor')
ylabel('APD (ms)')