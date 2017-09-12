close all
clear all

test_output_dir = '/export/testoutput/TestApdProfile/';

summary_d = importdata([test_output_dir 'APDs.dat']);

resolution = 200;
max_GNa = 0.2;
gKr_value = 0.5;

figure(1)

for i=1:resolution+1
    file_name = [test_output_dir 'ohara_rudy_2011_' num2str(max_GNa.*(i-1.0)./resolution) '_' num2str(gKr_value) '_.dat'];
    d = importdata(file_name);
    
    g_Na_factor = max_GNa*(i-1.0)/resolution;
    
    figure(1)
    plot3(d.data(:,1), ones(length(d.data),1).*g_Na_factor, d.data(:,2), '-')
    hold all
    
    % plot some troublesome ones
    if i>=91 && i<=98
    figure
    plot(d.data(:,1), d.data(:,2), 'b-')
    hold on
    plot(d.data(1001:2001,1), d.data(1:1001,2), 'r-')
    plot(d.data(1:1001,1), d.data(1001:2001,2), 'r-')
    xlabel('Time (ms)')
    ylabel('Voltage (mV)')
    title(['Trace ' num2str(i) ' with gNa = ' num2str(g_Na_factor) ' Error code = ' num2str(summary_d.data(i,5))])
    end
end

figure(1)
xlabel('Time (ms)')
ylabel('gNa scaling factor')
zlabel('Voltage (mV)')



figure
plot(summary_d.data(:,2),summary_d.data(:,4),'.-')
xlabel('gNa scaling factor')
ylabel('APD (ms)')
hold on
plot(summary_d.data(:,2),100*summary_d.data(:,5),'x')



