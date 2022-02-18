
clear flag
for ii = 1:length(Slink_g3.connected)
    flag(ii) = (length(Slink_g3.connected(ii).name)==1);
end

plot_end_node.radii = Slink_g3.radii(flag);
plot_end_node.skel = Slink_g3.skel(flag);
plot_end_node.group = Slink_g3.group(flag);

Slink_g1.normal = ismember(Slink_g1.group,plot_end_node.group);
Slink_g3.normal = ismember(Slink_g3.group,plot_end_node.group);


%{
figure()

[xxx, yyy, zzz] = ind2sub(CropSize, plot_end_node.skel);
color3 = [plot_end_node.radii./5 1-plot_end_node.radii./5 zeros(size(xxx))];
scatter3(xxx,yyy,zzz,plot_end_node.radii.*8.0, color3,'filled');

axis equal	
%}


figure()

[xxx, yyy, zzz] = ind2sub(CropSize, Slink_g1.skel);
color3 = [Slink_g1.normal 1-Slink_g1.normal zeros(size(xxx))];
scatter3(xxx,yyy,zzz,Slink_g1.radii.*8.0, color3,'filled');


hold

[xxx, yyy, zzz] = ind2sub(CropSize, Slink_g3.skel);
color3 = [Slink_g3.normal 1-Slink_g3.normal zeros(size(xxx))];
scatter3(xxx,yyy,zzz,Slink_g3.radii.*8.0, color3,'filled');

axis equal	


bad_link_length = sum(Slink_g1.length(Slink_g1.normal))
good_link_length = sum(Slink_g1.length(~Slink_g1.normal))

good_rato = good_link_length./(bad_link_length+good_link_length)