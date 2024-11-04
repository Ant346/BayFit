function isInside = isPointInsideEllipsoid(point, center, semiaxes, rotation_matrix)
    % Translate the point to the ellipsoid's local coordinate system
%     translated_point = point - center;

    point = point';
    D = diag(semiaxes.^(-2));
    A_rotated = rotation_matrix' * D * rotation_matrix;
    val = (point' * A_rotated *  point);
    isInside =  val <= 1;
    
    % Rotate the point to align with the principal axes of the ellipsoid
    % Using the inverse rotation matrix
    %rotated_point = rotation_matrix'* translated_point';
    
    % Check if the point is inside the ellipsoid
    %isInside = ((rotated_point(1) / semiaxes(1))^2 + (rotated_point(2) / semiaxes(2))^2 + (rotated_point(3) / semiaxes(3))^2) <= 1;
end