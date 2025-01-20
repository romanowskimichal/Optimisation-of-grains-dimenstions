function [new_grain_dimention] = SingleMultiplicatorForGrainWithFunctionChannel (grain_dimention, multiplicator)

% looking for first non-numeric character (later detemined if multiplicator consisting previous characters is at the beginning)
i = 1;
while any([grain_dimention(i) == '0',grain_dimention(i) == '1',grain_dimention(i) == '2',...
        grain_dimention(i) == '3',grain_dimention(i) == '4',grain_dimention(i) == '5',grain_dimention(i) == '6',...
        grain_dimention(i) == '7',grain_dimention(i) == '8',grain_dimention(i) == '9',grain_dimention(i) == '.'])
    i = i + 1;
end

% verification if the outer brackets cover the whole function (true if:
% 1) there are not any zeros in the middle,
% 2) and there is only one zero is at the end,
% 3) and there are zeros at the beginning, but only as a result of the multiplicator for whole rest of the function and '*')
open_brackets = zeros(length(grain_dimention),1);
open_brackets_boolean = zeros(length(grain_dimention),1);
if grain_dimention(1) == '('
    open_brackets(1) = 1;
end
for j=2:length(grain_dimention)
    if grain_dimention(j) == '('
        open_brackets(j) = open_brackets(j-1) + 1;
    elseif grain_dimention(j) == ')'
        open_brackets(j) = open_brackets(j-1) - 1;
    else
        open_brackets(j) = open_brackets(j-1);
    end
end
open_brackets_boolean(open_brackets~=0)=1;
for j=1:length(grain_dimention)
    if open_brackets(j) ~= 0
        open_brackets_boolean(j) = 1;
    end
end

% creating new_grain_dimention with a new, single multiplicator
if and(grain_dimention(i) == '*',all(open_brackets_boolean(i+1:end-1)))
    multiplicator_old = str2double(grain_dimention(1:i-1));
    multiplicator_whole = multiplicator*multiplicator_old;
    new_grain_dimention = strcat(num2str(multiplicator_whole),grain_dimention(i:end));
elseif and(and(grain_dimention(1) == '(',grain_dimention(end) == ')'),all(open_brackets_boolean(1:end-1)))
    new_grain_dimention = strcat(num2str(multiplicator),'*',grain_dimention);
else
    new_grain_dimention = strcat(num2str(multiplicator),'*(',grain_dimention,')');
end

end