function [group] = getAll_Groups(S_skel,CropSize)

[nhi,nh] = get_nh_save_memory(S_skel,CropSize);

selfList = (1:1:length(nh))';

linkListUp = [];
linkListDown = [];

for ii = 1:13
    linkListUpTemp = [selfList S_skel nhi(:,ii+14)];
    linkListUpTemp = linkListUpTemp(nh(:,ii+14),:) ;
    linkListUp = [linkListUp; linkListUpTemp];
    linkListDownTemp = [selfList S_skel nhi(:,ii)];
    linkListDownTemp = linkListDownTemp(nh(:,ii),:) ;
    linkListDown = [linkListDown; linkListDownTemp];
end


linkListDownSort = sortrows(linkListDown,3);
linkListUpSort = sortrows(linkListUp,2);

goodLinkTable = [linkListUpSort(:,1) linkListDownSort(:,1) ];
clear linkList*

% # of 26-nb of each skel voxel + 1



full_name = (1:1:length(S_skel))';
grouptemp = (1:1:length(S_skel))';

group_to_be_worked =0;

while ~isempty(group_to_be_worked )


    group_to_be_worked = goodLinkTable(grouptemp(goodLinkTable(:,1)) ~= grouptemp(goodLinkTable(:,2)),:);
    group_to_be_worked = [grouptemp(group_to_be_worked(:,1)); grouptemp(group_to_be_worked(:,2))];

    unique_list = unique(group_to_be_worked(:));
    list_to_expand = unique_list(rand(length(unique_list),1)>=0.5);
    
    Link_table_ind_temp = ismember(goodLinkTable(:,1), full_name(ismember(grouptemp,list_to_expand)));
    clear Glist
    Glist(:,1) = grouptemp(goodLinkTable(Link_table_ind_temp,1));
    Glist(:,2) = grouptemp(goodLinkTable(Link_table_ind_temp,2));
    Glist = Glist(~(Glist(:,1)  == Glist(:,2) ),:);
    Glist = Glist(~ismember(Glist(:,1),Glist(:,2)),:);
    
    [temp_logic, temp_ind] = ismember(grouptemp, Glist(:,1));
    grouptemp(temp_logic) = Glist(nonzeros(temp_ind),2);
    
    
    %fprintf([ num2str(length(unique(grouptemp))) '\n'])




end
    group = grouptemp;


            