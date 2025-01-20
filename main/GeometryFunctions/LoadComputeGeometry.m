function Inputs = LoadComputeGeometry (Inputs,output_path_name)
    %Load session
    Inputs = (jsondecode(input_geometry_string))';
    
    %Computing
    for i=1:length(Inputs.Geometry)
        %Geometry type detection
        if strcmp(Inputs.Geometry{i,1}.type,'Cylinder')
            Outputs.(Inputs.Geometry{i,1}.filename)=GeometryCylinder(Inputs.Geometry{i,1}.length_cyl,...
                Inputs.Geometry{i,1}.diameter_outer,Inputs.Geometry{i,1}.resolution);
        elseif strcmp(Inputs.Geometry{i,1}.type,'Tube')
            Outputs.(Inputs.Geometry{i,1}.filename)=GeometryTube(Inputs.Geometry{i,1}.length_cyl,...
                Inputs.Geometry{i,1}.diameter_outer,Inputs.Geometry{i,1}.diameter_inner,Inputs.Geometry{i,1}.resolution);
        elseif strcmp(Inputs.Geometry{i,1}.type,'MultiChannel')
            Outputs.(Inputs.Geometry{i,1}.filename)=GeometryMultiChannel(Inputs.Geometry{i,1}.length_cyl,...
                Inputs.Geometry{i,1}.diameter_outer,Inputs.Geometry{i,1}.channel_number,Inputs.Geometry{i,1}.channel_diameter,...
                Inputs.Geometry{i,1}.channel_ring_diameter,Inputs.Geometry{i,1}.resolution);
        elseif strcmp(Inputs.Geometry{i,1}.type,'Star')
            Outputs.(Inputs.Geometry{i,1}.filename)=GeometryStar(Inputs.Geometry{i,1}.length_cyl,...
                Inputs.Geometry{i,1}.diameter_outer,Inputs.Geometry{i,1}.star_arms_number,Inputs.Geometry{i,1}.star_outer_diameter,...
                Inputs.Geometry{i,1}.star_arm_angle,Inputs.Geometry{i,1}.resolution);
        elseif strcmp(Inputs.Geometry{i,1}.type,'FunctionChannel')
            Outputs.(Inputs.Geometry{i,1}.filename)=GeometryFunctionChannel(Inputs.Geometry{i,1}.length_cyl,...
                Inputs.Geometry{i,1}.diameter_outer,Inputs.Geometry{i,1}.radial_function,Inputs.Geometry{i,1}.resolution);   %angle in radians
        end
        %View geometry detection
        if strcmp(Inputs.Geometry{i,1}.view_parameters.viewGeometry,'yes')
            ViewGeometry(Outputs.(Inputs.Geometry{i,1}.filename),...
                Inputs.Geometry{i,1}.view_parameters.transparency_surfaces,Inputs.Geometry{i,1}.view_parameters.scale_normals);
        end
        %Save as .stl detection
        if strcmp(Inputs.Geometry{i,1}.saveSTL,"yes")
            MatrixtoSTL(Outputs.(Inputs.Geometry{i,1}.filename),...
                strcat(output_path_name,Inputs.Geometry{i,1}.filename,".stl"));
        end
    end
end