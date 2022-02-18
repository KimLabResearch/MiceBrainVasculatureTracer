function [Slink_g1, Slink_g3] = calculat_length(S_link, S_new,CropSize)

[goodLinkTable] = getAllLinks_save_memory(S_new.skel,CropSize);

S_new.nh_name = get_nh_names(length(S_new.skel), goodLinkTable);
S_new.nh_name(logical(S_new.nh_name(:))) = S_new.name(S_new.nh_name(logical(S_new.nh_name(:))));



S_link.nh_name =  S_new.nh_name(ismember(S_new.name, S_link.name),:);
sum_nh_name_link = sum(logical(S_link.nh_name),2);

Slink_g1 = structfun(@(x) (x(sum_nh_name_link == 2,:)), S_link, 'UniformOutput', false);





[goodLinkTable_Link] = getAllLinks_save_memory(Slink_g1.skel,CropSize);
Slink_g1.subgroup = grouping_remake(length(Slink_g1.skel), goodLinkTable_Link);
Slink_g1.subgroup = Slink_g1.name(Slink_g1.subgroup);

[link_group_list] = unique(Slink_g1.subgroup);



Slink_g1_g.length = histc(Slink_g1.subgroup,link_group_list);

badLinks = link_group_list(Slink_g1_g.length<5);


removal = ismember( Slink_g1.subgroup,badLinks);

Slink_g1 = structfun(@(x) (removerows(x, 'ind', removal)), Slink_g1, 'UniformOutput', false);

logic3 = ismember(S_new.name,Slink_g1.name);
Slink_g2 = structfun(@(x) (removerows(x, 'ind', logic3)), S_new, 'UniformOutput', false);


[goodLinkTable_Link] = getAllLinks_save_memory(Slink_g2.skel,CropSize);
Slink_g2.subgroup = grouping_remake(length(Slink_g2.skel), goodLinkTable_Link);
Slink_g2.subgroup = Slink_g2.name(Slink_g2.subgroup);

[link_group_list] = unique(Slink_g2.subgroup);

Slink_g3.name = [];
Slink_g3.skel = [];
Slink_g3.group = [];
Slink_g3.radii = [];

for ii = 1:length(link_group_list)
    who_is_group = Slink_g2.name(Slink_g2.subgroup == link_group_list(ii));
    who_is_connected = nonzeros(unique(Slink_g2.nh_name(Slink_g2.subgroup == link_group_list(ii),:)));
    
    who_is_group_ii = find(Slink_g2.subgroup == link_group_list(ii));
    
    
    who_is_group_skel = S_new.skel(ismember(S_new.name,who_is_group));
    [w_xx, w_yy, w_zz] = ind2sub(CropSize,who_is_group_skel);
    
    Slink_g3.skel(ii) = sub2ind(CropSize,round(mean(w_xx)),round(mean(w_yy)),round(mean(w_zz)));
    Slink_g3.name(ii) = Slink_g2.name(who_is_group_ii(1));
    Slink_g3.group(ii) = Slink_g2.group(who_is_group_ii(1));
    Slink_g3.radii(ii) = max(Slink_g2.radii(who_is_group_ii));
    Slink_g3.connected(ii).name = who_is_connected(~ismember(who_is_connected,who_is_group));
    Slink_g3.connected(ii).skel = S_new.skel(ismember(S_new.name, Slink_g3.connected(ii).name));
    if length(who_is_connected(~ismember(who_is_connected,who_is_group))) ==2
        [w_xx, w_yy, w_zz] = ind2sub(CropSize,Slink_g3.connected(ii).skel);
        Slink_g3.length(ii) = sqrt((w_xx(1)-w_xx(2)).*(w_xx(1)-w_xx(2)) + (w_yy(1)-w_yy(2)).*(w_yy(1)-w_yy(2)) + (w_zz(1)-w_zz(2)).*(w_zz(1)-w_zz(2)));
    else
        Slink_g3.length(ii) = 0;
    end
    
end

[~, temp_ic ] = ismember(Slink_g1.name,S_new.name);

Slink_g1.connected.name = sort(S_new.nh_name(temp_ic,:),2);
Slink_g1.connected.name = Slink_g1.connected.name(:,end-1:end);
[~, temp_ic ] = ismember(Slink_g1.connected.name,S_new.name);
Slink_g1.connected.skel = S_new.skel(temp_ic);

[w_xx1, w_yy1, w_zz1] = ind2sub(CropSize,Slink_g1.connected.skel(:,1));
[w_xx2, w_yy2, w_zz2] = ind2sub(CropSize,Slink_g1.connected.skel(:,2));
Slink_g1.length = sqrt((w_xx1-w_xx2).*(w_xx1-w_xx2) + (w_yy1-w_yy2).*(w_yy1-w_yy2) + (w_zz1-w_zz2).*(w_zz1-w_zz2))./2;


Slink_g3 = structfun(@(x) (x'), Slink_g3, 'UniformOutput', false);


