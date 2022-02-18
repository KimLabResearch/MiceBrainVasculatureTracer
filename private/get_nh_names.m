function nh_name = get_nh_names(length_of_S_skel, goodLinkTable)

nh_name = zeros(length_of_S_skel,26);

goodLinkTable2 = [goodLinkTable(:,2) goodLinkTable(:,1)];
goodLinkTable2 = sortrows(goodLinkTable2);

list13 = false(length(goodLinkTable),13);
selfLink = (1:1:length(goodLinkTable))';
for ii = 1:1:13
    list13(mod(selfLink,13)==ii-1,ii) = 1;
end

    
for ii =1:1:13
    nh_name(goodLinkTable(list13(:,ii),1),ii) = goodLinkTable(list13(:,ii),2);
    nh_name(goodLinkTable2(list13(:,ii),1),ii+13) = goodLinkTable2(list13(:,ii),2);
end
