close all
clear all

test_output_dir = '/export/testoutput/TestApdSurface2D/';

d = importdata([test_output_dir 'APDs.dat']);

figure(1)

error_labels = unique(d.data(:,5));

for err_code = 1:length(error_labels)

    idxs = find(d.data(:,5) == error_labels(err_code));
    h{err_code} = plot3(d.data(idxs,2), d.data(idxs,3), d.data(idxs,4), '.');
    hold all

end
xlabel('gNa scaling factor')
ylabel('gKr scaling factor')
zlabel('APD (ms)')
legend([h{1:end}],{'APD','NoAP_1','NoAP_2','NoAP_3','NoAP_4','NoAP_5','NoAP_6','NoAP_7'})
