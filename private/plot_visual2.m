close all

%Visp = 385 %SomatoSensory = 453 %PTLp = 22 
%SSp-n = 353  %91 = PIR %703 = CTXsp
% 698 = OLF  %909 = ENT
% 549 = Thalamus  %375 = Ammon's horn
%485 = Striatum dorsal region

figure();
hold


reading_ID = 22;
filename1 = [num2str(reading_ID) '.mat'];
filename2 = [ 'young\' num2str(reading_ID) '.mat'];


load(filename2);
f = histogram(link_group.radii,'normalization','probabilit','DisplayStyle', 'stairs','BinWidth',0.05);



reading_ID = 375;
filename1 = [num2str(reading_ID) '.mat'];
filename2 = [ 'young\' num2str(reading_ID) '.mat'];


load(filename2);
f = histogram(link_group.radii,'normalization','probabilit','DisplayStyle', 'stairs','BinWidth',0.05);



reading_ID = 453;
filename1 = [num2str(reading_ID) '.mat'];
filename2 = [ 'young\' num2str(reading_ID) '.mat'];


load(filename2);
f = histogram(link_group.radii,'normalization','probabilit','DisplayStyle', 'stairs','BinWidth',0.05);

reading_ID = 485;
filename1 = [num2str(reading_ID) '.mat'];
filename2 = [ 'young\' num2str(reading_ID) '.mat'];


load(filename2);
f = histogram(link_group.radii,'normalization','probabilit','DisplayStyle', 'stairs','BinWidth',0.05);

reading_ID = 549;
filename1 = [num2str(reading_ID) '.mat'];
filename2 = [ 'young\' num2str(reading_ID) '.mat'];


load(filename2);
f = histogram(link_group.radii,'normalization','probabilit','DisplayStyle', 'stairs','BinWidth',0.05);

reading_ID = 909;
filename1 = [num2str(reading_ID) '.mat'];
filename2 = [ 'young\' num2str(reading_ID) '.mat'];


load(filename2);
f = histogram(link_group.radii,'normalization','probabilit','DisplayStyle', 'stairs','BinWidth',0.05);




xlim([0 4])





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