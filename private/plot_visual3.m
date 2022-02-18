%close all

%Visp = 385 %SomatoSensory = 453 %PTLp = 22 
%SSp-n = 353  %91 = PIR %703 = CTXsp
% 698 = OLF  %909 = ENT
% 549 = Thalamus  %375 = Ammon's horn
%485 = Striatum dorsal region

figure();
hold


reading_ID_list = [22 375 453 485 549 909];
marker_list{1} = '+';
marker_list{2} = 'o';
marker_list{3} = '*';
marker_list{4} = '.';
marker_list{5} = 'x';
marker_list{6} = 's';

for iiii =1:length(reading_ID_list)

reading_ID = reading_ID_list(iiii);
filename1 = [num2str(reading_ID) '.mat'];
filename2 = [ 'young\' num2str(reading_ID) '.mat'];


load(filename2);
[N,edges] = histcounts(link_group.radii, 'BinWidth',0.05);
edges = edges(2:end) - (edges(2)-edges(1))/2;
N = N./total_Volume.*1E9./0.05;
area(edges, N, 'LineStyle', 'none');
plot(edges, N, [':k' marker_list{iiii}  ]);

alpha(.2);

drawnow()

end




xlim([1.2 3.2])





%set(gca, 'YScale', 'log')


%{
filename1 = [num2str(reading_ID) '.mat'];
filename2 = [ 'young\' num2str(reading_ID) '.mat'];


load(filename2);

figure();
f = histogram(link_group.length,'BinWidth',5);
xlim([0 500])
median(link_group.length)

hold

load(filename1);

g = histogram(link_group.length,'BinWidth',5);
median(link_group.length)

hold
%}


%{
load(filename2);

figure();
scatter1 = scatter(link_group.radii,link_group.length,'x');
xlim([0 5])
ylim([0 500])



load(filename1);
figure();
scatter1 = scatter([],[],'x');
hold
scatter1 = scatter(link_group.radii,link_group.length,'+');

xlim([0 5])
ylim([0 500])
hold
%}