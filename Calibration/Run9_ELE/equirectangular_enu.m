function [xEast, yNorth, zUp] = equirectangular_enu(lat, lon, alt, lat0, lon0, alt0)
    % Simple local ENU conversion using small-angle approx:
    % lat,lon in degrees (vectors), returns xEast, yNorth, zUp in meters
    R_earth = 6378137; % mean Earth radius [m]
    dlat = deg2rad(lat - lat0);
    dlon = deg2rad(lon - lon0);
    lat0rad = deg2rad(lat0);
    xEast = R_earth * dlon .* cos(lat0rad);
    yNorth = R_earth * dlat;
    zUp = alt - alt0;
    % make column vectors
    xEast = xEast(:); yNorth = yNorth(:); zUp = zUp(:);
end