function [regionIDList region] = readAllenRegionAnnotationFile()

%% Read the excel'98 file save from MSExcel generated on mac
csvFileName = './atlas_info_KimRef_v3.csv';

%[num, txt, raw] = xlsread (xlsFileName);
regionIDList = [];

filePtr = fopen (csvFileName);
line = 0;
iLine = 1;
fieldDelimiter = ',';
stringDelimiter = '"';

region(65535).id = [];

while (~(line == -1))
    line = fgetl (filePtr);
    [region_id reminderText] = getField (line, fieldDelimiter, stringDelimiter);
    [region_name reminderText] = getField (reminderText, fieldDelimiter, stringDelimiter);
    [region_acronym reminderText] = getField (reminderText, fieldDelimiter, stringDelimiter);
    [region_red reminderText] = getField (reminderText, fieldDelimiter, stringDelimiter);
    [region_green reminderText] = getField (reminderText, fieldDelimiter, stringDelimiter);
    [region_blue reminderText] = getField (reminderText, fieldDelimiter, stringDelimiter);
    [region_structure_order reminderText] = getField (reminderText, fieldDelimiter, stringDelimiter);
    [region_parent_id reminderText] = getField (reminderText, fieldDelimiter, stringDelimiter);
    [region_parent_acronym reminderText] = getField (reminderText, fieldDelimiter, stringDelimiter);
   
    if ((iLine > 1) & (line ~= -1))
        region(region_id).id = region_id;
        region(region_id).name = region_name;
        region(region_id).acronym = region_acronym;
        region(region_id).red = region_red;
        region(region_id).green = region_green;
        region(region_id).blue = region_blue;
        region(region_id).stucture_order = region_structure_order;
        region(region_id).parent_id = region_parent_id;
        region(region_id).parent_acronym = region_parent_acronym;
        region(region_id).line_no = iLine;
        region(region_id).children_id = [];
        if ((region_parent_id == 0) || (isnan(region_parent_id)))
            %if nan or 0 don't do anything
        else
            region(region_parent_id).children_id = [region(region_parent_id).children_id region_id];
        end
        regionIDList = [regionIDList region_id];
    end
    iLine = iLine + 1;
end

fclose(filePtr);

function [field reminderText] = getField (text, fieldDelimiter, stringDelimiter)

if (size (text, 2) > 0)
    if (strcmp (text(1), stringDelimiter))
        [field reminderText] = strtok (text, stringDelimiter);
        reminderText = reminderText(2:end);
    else
        [field reminderText] = strtok (text, fieldDelimiter);
        field = str2double (field);
    end
    if (size (reminderText, 2) > 0)
        if (strcmp (reminderText(1), ','))
            reminderText = reminderText(2:end);
        end
    end
else
    field = '';
    reminderText = '';
end

