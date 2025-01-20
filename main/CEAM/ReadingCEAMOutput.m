function [names_in_output,values] = ReadingCEAMOutput (filename)

text=fileread(filename);

% names used in CEA output file/string, needed to read for RPAT's input
names_in_output = ["T(K)";
    "Gammas";
    "M (1/n)";
    "Visc.(uPa-s)";
    "Cp(kJ/kg-K)";
    "Prandtl";
    "Cond."];

values = zeros(length(names_in_output),1);
for i = 1:length(names_in_output)
                                        % \/ found name end+1 in output
    j = strfind(text,names_in_output{i,1})+length(names_in_output{i,1});
    if length(j)>1
        j = j(1);                       % only first occurance
    end
    while (j<length(text) && (text(j)==' ' || text(j)==':'))
        j = j+1;
    end
    value_string = text(j);                    % found value beginning in output
    while (j<length(text) && text(j)~=' ')
        j = j+1;
        value_string = strcat(value_string,text(j));
    end                                 % found value end in output
    values(i) = str2double(value_string);      % values saved
end

% conversion to basic SI units (units notation as in CEA)
% mks - used as it contains most of basic units
values(4) = values(4)*10^-6;    % uPa-s -> Pa-s
values(5) = values(5)*10^3;     % kJ/kg-K -> J/kg-K
% default - other possible option
% values(4) = values(4)*10^-4;    % mPoise -> Pa-s
% values(5) = values(5)*10^3;     % kJ/kg-K -> J/kg-K
% values(7) = values(7)*10^-1;    % mW/cm-K -> W/m-K

end