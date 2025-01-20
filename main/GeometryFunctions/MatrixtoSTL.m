function MatrixtoSTL(geometry,filename)
    TR = triangulation(geometry.ConnectivityList,geometry.Points);
    stlwrite(TR,filename);
end