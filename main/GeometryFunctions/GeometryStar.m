function [geometryy]=GeometryStar(length_cyl,diameter,star_arms_number,star_outer_diameter,star_arm_angle,resolution)
    if (exist("resolution",'var'))&&~isnan(resolution)
        angle=linspace(0,2*pi,resolution)';
    else
        angle=linspace(0,2*pi)';
    end
    angle(end)=[];
    geometryy.Points=[zeros(length(angle),1),diameter/2*sin(angle),diameter/2*cos(angle);length_cyl*ones(length(angle),1),diameter/2*sin(angle),diameter/2*cos(angle)];
    geometryy.edge{1,1} = 1:length(angle);
    geometryy.edge{2,1} = (length(angle)+1):(2*length(angle));
    geometryy.edge{3,1} = [];
    geometryy.edge{4,1} = [];
    geometryy.surface{1,1} = 1;
    geometryy.surface{2,1} = [1,2];
    geometryy.surface{3,1} = 2;
    star_small_angle=pi/star_arms_number;
    star_arm_angle=star_arm_angle*pi/180; %deg to rad
    star_inner_diameter=star_outer_diameter*tan(star_arm_angle/2)/(tan(star_small_angle)+tan(star_arm_angle/2))/cos(star_small_angle);
    for i=1:star_arms_number
        geometryy.Points=[geometryy.Points;[0,star_inner_diameter/2*sin(((i-1)*2+1)*star_small_angle),star_inner_diameter/2*cos(((i-1)*2+1)*star_small_angle);...
            0,star_outer_diameter/2*sin((i*2)*star_small_angle),star_outer_diameter/2*cos((i*2)*star_small_angle)];...
            [length_cyl,star_inner_diameter/2*sin(((i-1)*2+1)*star_small_angle),star_inner_diameter/2*cos(((i-1)*2+1)*star_small_angle);...
            length_cyl,star_outer_diameter/2*sin((i*2)*star_small_angle),star_outer_diameter/2*cos((i*2)*star_small_angle)]];
        geometryy.edge{3,1} = [geometryy.edge{3,1},height(geometryy.Points)-3,height(geometryy.Points)-2];
        geometryy.edge{4,1} = [geometryy.edge{4,1},height(geometryy.Points)-1,height(geometryy.Points)];
    end
    geometryy.surface = {[1,3];[1,2];[2,4];[3,4]};
    geometryy = ConnectivityListCreation(geometryy);
end