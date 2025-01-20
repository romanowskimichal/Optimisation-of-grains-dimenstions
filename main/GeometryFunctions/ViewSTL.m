function ViewSTL(filename,transparency_surfaces)
    input = stlread(filename);
    figure;
    trisurf(input,'FaceColor','cyan','FaceAlpha',transparency_surfaces);
    axis equal
end