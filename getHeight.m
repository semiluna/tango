function z = getHeight(x,y)
%GETHEIGHT obtains z coordinate for a given x and y
%   Uses a heightmap file, which holds a list of coordinates taken at
%   regular 10m x and y intervals across the ground. The function
%   interpolates between the heights of the corners of the square the input
%   is in.
    x_factor = (x/10) - floor(x/10);
    y_factor = (y/10) - floor(y/10);
    
    file_text = fileread('heightmap.txt');
    lines = splitlines(file_text);
    line_num = floor(x/10)+56;
    coord_num = floor(y/10)+31;
    
    if line_num == 0
        coords1 = split(lines(1), ", ");
    else
        coords1 = split(lines(line_num), ", ");
    end
    if line_num == 107
        coords2 = split(lines(line_num), ", ");
    else
        coords2 = split(lines(line_num+1), ", ");
    end
    
    if coord_num == 0
        lxly = coords1(1);
        hxly = coords2(1);
    else
        lxly = coords1(coord_num);
        hxly = coords2(coord_num);
    end
    if coord_num == 61
        lxhy = coords1(coord_num);
        hxhy = coords2(coord_num);
    else
        lxhy = coords1(coord_num+1);
        hxhy = coords2(coord_num+1);
    end
    
    lxly_split = split(lxly,",");
    lxhy_split = split(lxhy,",");
    hxly_split = split(hxly,",");
    hxhy_split = split(hxhy,",");
    
    lxly_z_str = lxly_split(3);
    lxly_z_str = extractBetween(lxly_z_str,1, strlength(lxly_z_str)-1);
    lxly_z = str2double(lxly_z_str);
    
    hxly_z_str = hxly_split(3);
    hxly_z_str = extractBetween(hxly_z_str,1, strlength(hxly_z_str)-1);
    hxly_z = str2double(hxly_z_str);
    
    lxhy_z_str = lxhy_split(3);
    lxhy_z_str = extractBetween(lxhy_z_str,1, strlength(lxhy_z_str)-1);
    lxhy_z = str2double(lxhy_z_str);
    
    hxhy_z_str = hxhy_split(3);
    hxhy_z_str = extractBetween(hxhy_z_str,1, strlength(hxhy_z_str)-1);
    hxhy_z = str2double(hxhy_z_str);
    
    z = x_factor*y_factor*hxhy_z + x_factor*(1-y_factor)*hxly_z + (1-x_factor)*y_factor*lxhy_z + (1-x_factor)*(1-y_factor)*lxly_z;
end

