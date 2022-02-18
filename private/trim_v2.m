function [S_link,  wierdNode, S_new] = trim_v2(S_skel,S_radii,CropSize,trimLevel)
fprintf(['Triming the skeleton artifacts'    '\n'])
tic

S_OG.skel = S_skel;
S_OG.radii = S_radii;
S_OG.name = (1:1:length(S_skel))';
S_OG.group = (1:1:length(S_skel))';

S_new = S_OG;





[~,nh] = get_nh_save_memory(S_skel,CropSize);


selfList = (1:1:length(nh))';
sum_nh = sum(logical(nh),2);


%%%% dealing with links

S_link.name = selfList(sum_nh==3);
S_link.skel = S_skel(sum_nh==3);

[goodLinkTable_Link] = getAllLinks_save_memory(S_link.skel,CropSize);
S_link.group = grouping_remake(length(S_link.skel), goodLinkTable_Link);
S_link.group = S_link.name(S_link.group);

[link_group_list] = unique(S_link.group);


S_link_g.length = histc(S_link.group,link_group_list);

badLinks = link_group_list(S_link_g.length<5);




removal = ismember( S_link.group,badLinks);
wierdNodePile = S_link.name(removal);
wierdNodePile = wierdNodePile(logical(wierdNodePile));


%%%% dealing with wierdNode_group

wierdNodePile2 = selfList(sum_nh>3 | sum_nh == 2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wierdNodePile2 = [wierdNodePile2;  wierdNodePile];
S_link = structfun(@(x) (removerows(x, 'ind', removal)), S_link, 'UniformOutput', false);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


wierdNode.name = sort(wierdNodePile2);



clear wierdNodePile wierdNodePile2
wierdNode.skel = S_skel(wierdNode.name);



S_old.name = 0;

while ~isequal(S_new.name,S_old.name)
    
    S_old.name = S_new.name;
    
    
    
    [goodLinkTable] = getAllLinks_save_memory(S_new.skel,CropSize);
    
    nh_name = get_nh_names(length(S_new.skel), goodLinkTable);
    nh_name(logical(nh_name(:))) = S_new.name(nh_name(logical(nh_name(:))));
    
    
    [goodLinkTable_wiered] = getAllLinks_save_memory(wierdNode.skel,CropSize);
    
    wierdNode.group = grouping_remake(length(wierdNode.skel), goodLinkTable_wiered);
    wierdNode.group = wierdNode.name(wierdNode.group);
    
    [wierdNode_group.name] = unique(wierdNode.group);
    
    
    wierdNode_group.num_connect = zeros(length(wierdNode_group.name),1);
    wierdNode_group.name_connected_to = zeros(length(wierdNode_group.name),26);
    
    for ii = 1:length(wierdNode_group.name)
        whoInGroup = wierdNode.name(wierdNode.group == wierdNode_group.name(ii));
        nh_name_inGroup = nh_name(ismember(S_new.name,whoInGroup),:);
        nh_name_inGroup = nh_name_inGroup(logical(nh_name_inGroup));
        logic_who_not_in_group = ~ismember(nh_name_inGroup,whoInGroup);
        name_who_not_in_group = unique(nh_name_inGroup(logic_who_not_in_group));
        if ~isempty(name_who_not_in_group)
            
            wierdNode_group.name_connected_to(ii,1:length(name_who_not_in_group)) = name_who_not_in_group';
        end
        Number_of_outSideLink = length(name_who_not_in_group);
        wierdNode_group.num_connect(ii) = Number_of_outSideLink;
        
    end
    
    
    jj = wierdNode_group.num_connect == 2;
    group_its_self = wierdNode_group.name(jj);
    
    to_be_remove = ismember(wierdNode.group,group_its_self);
    S_link.name = sort([S_link.name; wierdNode.name(to_be_remove)]);
    S_link.skel = S_skel(S_link.name);
    
    [goodLinkTable_Link] = getAllLinks_save_memory(S_link.skel,CropSize);
    S_link.group = grouping_remake(length(S_link.skel), goodLinkTable_Link);
    
    
    wierdNode = structfun(@(x) (removerows(x, 'ind', to_be_remove)), wierdNode, 'UniformOutput', false);
    
    
    
    
    
    
    
    
    
    
    %%% end-node
    
    
    jj = find(wierdNode_group.num_connect == 1);
    fprintf([num2str(length(jj)) '\n']);
    
    nameTemp = wierdNode_group.name_connected_to(jj,:);
    nameTemp = nonzeros(nameTemp);
    [~, group_name_temp] = ismember(nameTemp,S_link.name);
    group_connected_to = S_link.group(group_name_temp);
    group_its_self = wierdNode_group.name(jj);
    larger_Group_name = max(group_connected_to,group_its_self);
    
    [group_logic_temp, group_name_temp] = ismember(wierdNode_group.name, group_its_self);
    wierdNode_group.name(group_logic_temp) = larger_Group_name(nonzeros(group_name_temp));
    
    [group_logic_temp, group_name_temp] = ismember(wierdNode.group, group_its_self);
    wierdNode.group(group_logic_temp) = larger_Group_name(nonzeros(group_name_temp));
    
    [group_logic_temp, group_name_temp] = ismember(S_link.group, group_connected_to);
    S_link.group(group_logic_temp) = larger_Group_name(nonzeros(group_name_temp));
    
    
    
    
    
    
    %%% end nodes triming
    
    
    
    S_OG.group(S_link.name) = S_link.group;
    S_OG.group(wierdNode.name) = wierdNode.group;
    
    
    
    jj = find(wierdNode_group.num_connect <= 1);
    
    to_be_removed_1 = false(length(wierdNode.group),1);
    to_be_removed_2 = false(length(S_link.group),1);
    
    
    for ii = 1:length(jj)
        group_its_self = wierdNode_group.name(jj(ii));
        logic1 = wierdNode.group == group_its_self;
        logic2 = S_link.group == group_its_self;
        group_size = sum(logic1)+sum(logic2);
        if group_size < trimLevel
            to_be_removed_1 = to_be_removed_1 | logic1;
            to_be_removed_2 = to_be_removed_2 | logic2;
            
        end
        
    end
    
    wierdNode = structfun(@(x) (removerows(x, 'ind', to_be_removed_1)), wierdNode, 'UniformOutput', false);
    S_link = structfun(@(x) (removerows(x, 'ind', to_be_removed_2)), S_link, 'UniformOutput', false);
    logic3 = ~(ismember(S_OG.name,S_link.name) | ismember(S_OG.name,wierdNode.name));
    S_new = structfun(@(x) (removerows(x, 'ind', logic3)), S_OG, 'UniformOutput', false);
    
    
    fprintf(['skeleton points left: ' num2str(length(S_new.name))  '\n'])
    
end

[~, ind_temp] = ismember(S_link.name,S_new.name);
S_link.radii = S_new.radii(ind_temp);

[~, ind_temp] = ismember(wierdNode.name,S_new.name);
wierdNode.radii = S_new.radii(ind_temp);








toc