function input_json_RFSrocket_with_new_motor = ProperObjectMassForNewMotor (input_json_RFSrocket_with_new_motor)

% sprawdzi dzieci pierwszego obiektu
% będzie schodził na sam dół drzewka dzieci sumując masy ostatecznych 
% dzieci-stopni i silników (odczyta masę początkową silnika, gdy ten się
% pojawi)

% creation of table with child/non-child (1/0) information
new_objects = zeros(length(input_json_RFSrocket_with_new_motor));
for i = 1:length(input_json_RFSrocket_with_new_motor)
    objects_names{i} = input_json_RFSrocket_with_new_motor{i}.name;
end
for i = 1:length(input_json_RFSrocket_with_new_motor)
    if ~isempty(input_json_RFSrocket_with_new_motor{i, 1}.next_objects)
        new_objects(i,:) = ismember(objects_names, input_json_RFSrocket_with_new_motor{i, 1}.next_objects);
    end
end

% I assume chronological description of stages, thus this for is from end
% to 1
new_dry_masses = zeros(length(input_json_RFSrocket_with_new_motor), 1);
new_motor_masses = zeros(length(input_json_RFSrocket_with_new_motor), 1);
for i = 1:length(input_json_RFSrocket_with_new_motor)
    j = length(input_json_RFSrocket_with_new_motor)-i+1;
    % dry mass
    if all(new_objects(j,:) == 0)
        new_dry_masses(j) = input_json_RFSrocket_with_new_motor{j,1}.m_0;
    else
        temp_indices = find(new_objects(j,:)>0);
        for k = 1:length(temp_indices)
            temp_m_0_of_indices(k) = input_json_RFSrocket_with_new_motor{temp_indices(k),1}.m_0;
        end
        new_dry_masses(j) = sum(temp_m_0_of_indices) ...
            + sum(new_motor_masses(temp_indices)); % adding it here there no chance to add mass of motor from currently analysed object
    end
    % motor (this way is proper as last object doesn't have children especially with motor)
    if isfield(input_json_RFSrocket_with_new_motor{j,1},'Motor_Parameters')
        [~, ~, m_p_interp, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = GetMotor(input_json_RFSrocket_with_new_motor{j,1}.Motor_Parameters.filepath);
        new_motor_masses(j) = m_p_interp.Values(1);
    end
end

for i = 1:length(input_json_RFSrocket_with_new_motor)
    input_json_RFSrocket_with_new_motor{i,1}.m_0 = new_dry_masses(i);
end


end