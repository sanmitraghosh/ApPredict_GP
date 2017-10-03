close all
clear all

test_output_dir = '/export/testoutput/TestApdSurface2D/';

d = importdata([test_output_dir 'APDs.dat']);

figure(1)

error_labels = sort(unique(d.data(:,5)));

for err_code = 1:length(error_labels)

    idxs = find(d.data(:,5) == error_labels(err_code));
    h{err_code} = plot3(d.data(idxs,2), d.data(idxs,3), d.data(idxs,4), '.');
    hold all

end
xlabel('gNa scaling factor')
ylabel('gKr scaling factor')
zlabel('APD (ms)')

error_code_names{1} = 'APD';
for i=2:length(error_labels)
    error_code_names{i} = ['NoAP_' num2str(error_labels(i))];
end


legend([h{1:end}],error_code_names)
