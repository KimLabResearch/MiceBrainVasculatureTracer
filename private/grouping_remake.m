function group = grouping_remake(length_of_S_skel, goodLinkTable)



full_name = (1:1:length_of_S_skel)';
grouptemp = (1:1:length_of_S_skel)';

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


            
           