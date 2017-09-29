close all
clear all

test_output_dir = '/export/testoutput/TestApdProfile/';

summary_d = importdata([test_output_dir 'APDs.dat']);

resolution = 200;
max_GKr = 0.06;
gNa_value = 0.5;

figure(1)

for i=1:resolution+1
    gKr_value = max_GKr.*(i-1.0)./resolution;
    file_name = [test_output_dir 'ohara_rudy_2011_' num2str(gNa_value) '_' num2str(gKr_value) '_.dat'];
    d = importdata(file_name);
        
    figure(1)
    plot3(d.data(:,1), ones(length(d.data),1).*gKr_value, d.data(:,2), '-')
    hold all
    
    % plot some troublesome ones
    if i>=142 && i<=149
    figure
    plot(d.data(:,1), d.data(:,2), 'b-')
    hold on
    plot(d.data(1001:2001,1), d.data(1:1001,2), 'r-')
    plot(d.data(1:1001,1), d.data(1001:2001,2), 'r-')
    xlabel('Time (ms)')
    ylabel('Voltage (mV)')
    title(['Trace ' num2str(i) ' with gKr = ' num2str(gKr_value) ' Error code = ' num2str(summary_d.data(i,5))])
    end
end

figure(1)
xlabel('Time (ms)')
ylabel('gKr scaling factor')
zlabel('Voltage (mV)')


figure
plot(summary_d.data(:,3),summary_d.data(:,4),'.-')
xlabel('gKr scaling factor')
ylabel('APD (ms)')
hold on
plot(summary_d.data(:,3),100*summary_d.data(:,5),'x')



