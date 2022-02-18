bin_1_data.binsize = 0.1;


plot_1_data = link_group;

plot_1_data.prebin = round(plot_1_data.radii./bin_1_data.binsize);

bin_1_data.radii = bin_1_data.binsize:bin_1_data.binsize:5;
bin_1_data.total_length = zeros(size(bin_1_data.radii));




for ii = 1:length(plot_1_data.radii)
    if plot_1_data.prebin(ii)<= length(bin_1_data.total_length)
        
        bin_1_data.total_length(plot_1_data.prebin(ii)) = bin_1_data.total_length(plot_1_data.prebin(ii)) + plot_1_data.length(ii);
        
    end
    
end

%figure()
plot(bin_1_data.radii, bin_1_data.total_length./total_Volume);

