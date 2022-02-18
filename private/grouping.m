function group = grouping(length_of_S_skel, goodLinkTable)

tic
grouptemp = (1:1:length_of_S_skel)';

grouptemp1 = zeros(length_of_S_skel,10);

group = zeros(length_of_S_skel,1);

goodLinkTable2 = [goodLinkTable(:,2) goodLinkTable(:,1)];
goodLinkTable2 = sortrows(goodLinkTable2);

list13 = false(length(goodLinkTable),5);
selfLink = (1:1:length(goodLinkTable))';
for ii = 1:1:5
    list13(mod(selfLink,5)==ii-1,ii) = 1;
    grouptemp1(:,ii) = (1:1:length_of_S_skel)';
    grouptemp1(:,ii+5) = (1:1:length_of_S_skel)';
end

iii = 1;


while ~isequal(group, grouptemp)
    group = grouptemp;
    
    for ii =1:1:5
    grouptemp1(goodLinkTable(list13(:,ii),1),ii) = group(goodLinkTable(list13(:,ii),2));
    grouptemp1(goodLinkTable2(list13(:,ii),1),ii+5) = group(goodLinkTable2(list13(:,ii),2));
    end
    grouptemp =  max(grouptemp1 ,[],2);
    
   
    
    if mod(iii,10)==0
        [C] = unique(group);
        fprintf(['Loop #' num2str(iii) ' group left: ' num2str(length(C)) '\n'  ])

    end
    iii = iii+1;
end
toc
