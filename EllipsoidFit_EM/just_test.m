% Define the center and semiaxes of the ellipsoid
center = [0, 0, 0];
semiaxes = [3, 2, 1];

% Generate a grid of points in spherical coordinates
% [u, v] = meshgrid(linspace(0, 2*pi, 100), linspace(0, pi, 100));
% 
% % Convert spherical coordinates to Cartesian coordinates
% x = semiaxes(1) * cos(u) .* sin(v) + center(1);
% y = semiaxes(2) * sin(u) .* sin(v) + center(2);
% z = semiaxes(3) * cos(v) + center(3);
% 
% % Plot the surface of the ellipsoid
% figure;
% surf(x, y, z, 'FaceColor', 'b', 'EdgeColor', 'none');
% axis equal; % To ensure equal scaling along all axes
% title('3D Ellipsoid Surface');

% Define the bounding box
min_coords = center - semiaxes;
max_coords = center + semiaxes;

% Generate random points within the bounding box
num_points = 10000;
points = rand(num_points, 3) .* (max_coords - min_coords) + min_coords;

% Check which points are inside the ellipsoid
inside_points = sum(((points - center) ./ semiaxes).^2, 2) <= 1;

% Extract the points that are inside the ellipsoid
inside_points = points(inside_points, :);

% Plot the filled volume
figure;
scatter3(inside_points(:, 1), inside_points(:, 2), inside_points(:, 3), 'filled');
axis equal; % To ensure equal scaling along all axes
title('3D Filled Ellipsoid');