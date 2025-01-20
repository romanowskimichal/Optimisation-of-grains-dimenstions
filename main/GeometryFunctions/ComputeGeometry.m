function [stl_path_name] = ComputeGeometry (Inputs,output_path_name,geometry_number,geometry_iter)
%Computing

%Geometry type detection
if strcmp(Inputs.Geometry{geometry_number,1}.type,'Cylinder')
    Outputs.(Inputs.Geometry{geometry_number,1}.filename)=GeometryCylinder(Inputs.Geometry{geometry_number,1}.length_cyl,...
        Inputs.Geometry{geometry_number,1}.diameter_outer,Inputs.Geometry{geometry_number,1}.resolution);
elseif strcmp(Inputs.Geometry{geometry_number,1}.type,'Tube')
    Outputs.(Inputs.Geometry{geometry_number,1}.filename)=GeometryTube(Inputs.Geometry{geometry_number,1}.length_cyl,...
        Inputs.Geometry{geometry_number,1}.diameter_outer,Inputs.Geometry{geometry_number,1}.diameter_inner,Inputs.Geometry{geometry_number,1}.resolution);
elseif strcmp(Inputs.Geometry{geometry_number,1}.type,'MultiChannel')
    Outputs.(Inputs.Geometry{geometry_number,1}.filename)=GeometryMultiChannel(Inputs.Geometry{geometry_number,1}.length_cyl,...
        Inputs.Geometry{geometry_number,1}.diameter_outer,Inputs.Geometry{geometry_number,1}.channel_number,Inputs.Geometry{geometry_number,1}.channel_diameter,...
        Inputs.Geometry{geometry_number,1}.channel_ring_diameter,Inputs.Geometry{geometry_number,1}.resolution);
elseif strcmp(Inputs.Geometry{geometry_number,1}.type,'Star')
    Outputs.(Inputs.Geometry{geometry_number,1}.filename)=GeometryStar(Inputs.Geometry{geometry_number,1}.length_cyl,...
        Inputs.Geometry{geometry_number,1}.diameter_outer,Inputs.Geometry{geometry_number,1}.star_arms_number,Inputs.Geometry{geometry_number,1}.star_outer_diameter,...
        Inputs.Geometry{geometry_number,1}.star_arm_angle,Inputs.Geometry{geometry_number,1}.resolution);
elseif strcmp(Inputs.Geometry{geometry_number,1}.type,'FunctionChannel')
    Outputs.(Inputs.Geometry{geometry_number,1}.filename)=GeometryFunctionChannel(Inputs.Geometry{geometry_number,1}.length_cyl,...
        Inputs.Geometry{geometry_number,1}.diameter_outer,Inputs.Geometry{geometry_number,1}.radial_function,Inputs.Geometry{geometry_number,1}.resolution);   %angle in radians
end
%View geometry detection
if strcmp(Inputs.Geometry{geometry_number,1}.view_parameters.viewGeometry,'yes')
    ViewGeometry(Outputs.(Inputs.Geometry{geometry_number,1}.filename),...
        Inputs.Geometry{geometry_number,1}.view_parameters.transparency_surfaces,Inputs.Geometry{geometry_number,1}.view_parameters.scale_normals);
end
%Save as .stl detection
stl_path_name =  strcat(output_path_name,'\',Inputs.Geometry{geometry_number,1}.filename,num2str(geometry_iter),'.stl');
if strcmp(Inputs.Geometry{geometry_number,1}.saveSTL,"yes")
    MatrixtoSTL(Outputs.(Inputs.Geometry{geometry_number,1}.filename), stl_path_name);
end

end