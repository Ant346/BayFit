%===========================
% Robust Ellipsoid-specific Fitting via expectation-maximization 
% Update 3.13.2023
%============================

clc;
close all;
clear;

tic

my_file = "our_data\0_0.0100"
std_n = 0.11
% read our data
% ptCloud = pcread(my_file + ".pcd").Location * 10;
% minx = min(ptCloud(:,1))
% miny=min(ptCloud(:,2))
% minz=min(ptCloud(:,3))
% 
% minmin = min(min(minx, miny), minz)
% ptCloud = ptCloud + minmin

% ptCloud = ptCloud+
py.importlib.import_module('numpy')



%% Test example ellipsoid
% 
% centerr = [5 7 8]
% semiaxiss = [30 55 90]
% rott = [80/180*pi 50/180*pi 0/180*pi]
test=my_file+".npz"
np = py.importlib.import_module('numpy');
my_pt_data = py.dict(np.load(test));


centerr =  double(my_pt_data{'center'})
semiaxiss =  double(my_pt_data{'semiaxis'})
rott = double(my_pt_data{'rotation'})

%ellParFit=[centerr(1,1) centerr(1,2) centerr(1,3) semiaxiss(1,1) semiaxiss(1,2) semiaxiss(1,3) rott(1,1) rott(1,2) rott(1,3) 0.51];

%% Generate example ellipsoid
ptFit=generate_ellipsoidal_data(1,200, std_n, true, centerr, semiaxiss, rott);
ptFit=[ptFit.sample;ptFit.outlier];

%ptFit.sample=ptCloud.Location
%ptFit.outlier = []

%% Compute outlierness
%ptFit=[ptFit.sample;ptFit.outlier];
% ptFit=ptFit.sample;
[rdos_score,X,X_normal]=outlier_det(ptFit);
inlier=ptFit(rdos_score<=2,:);
inlier_num=size(inlier,1);

fprintf("inlier_num: %d\n", inlier_num);


% ptFit=generate_ellipsoidal_data(1,200, std, true, ptCloud);

% ptFit=ptFit.sample;

%% Generate example ellipsoid
while inlier_num==0

disp("11")
%ptFit.sample=ptCloud.Location
%ptFit.outlier = []

%% Compute outlierness
%

[rdos_score,X,X_normal]=outlier_det(ptFit);
inlier=ptFit(rdos_score<=2,:);
inlier_num=size(inlier,1);
fprintf("inlier_num: %d\n", inlier_num);

end


init_center=mean(inlier,1);% mass center
outlierness=1-inlier_num/size(ptFit,1);

%% Initialization the ellipsoid parameter
ellParInit=[init_center 1 1 1 0 0 0];% init_center
ptInit=drawEllipsoid(ellParInit,1,sqrt(inlier_num));   

%% Normalization 
[Y,Y_normal]=data_normalize_input(ptInit);

%% Start fitting
normal.xd=X_normal.xd;
normal.yd=Y_normal.xd;
normal.xscale=X_normal.xscale;
normal.yscale=Y_normal.xscale;
[transform,iter,time_spend]=ellipsoid_fit_EM(X,Y,outlierness,normal);

%% Get final ellipsoid   
[FitEllipsoid]=ellipsoid_par(init_center,transform.R,transform.t);
    
%% Plot result   
figure
% subplot(1,3,1);
% plot3(ptFit(:,1),ptFit(:,2),ptFit(:,3),'r.');
% title("Input data");
% 
subplot(1,2,1);
hold on;
% plot3(ptFit(:,1),ptFit(:,2),ptFit(:,3),'r.');
Pp=drawEllipsoid(FitEllipsoid,2,40);
% title("The fitted ellipsoid");


FitEllipsoid
center = [FitEllipsoid(1), FitEllipsoid(2), FitEllipsoid(3)];
semiaxes = [FitEllipsoid(4), FitEllipsoid(5), FitEllipsoid(6)];

% Define the bounding box
min_coords = center - semiaxes;
max_coords = center + semiaxes;

% Generate random points within the bounding box
num_points = 5000;
points = rand(num_points, 3) .* (max_coords - min_coords) + min_coords;

% Check which points are inside the ellipsoid
inside_points = sum(((points - center) ./ semiaxes).^2, 2) <= 1;

% Extract the points that are inside the ellipsoid
inside_points = points(inside_points, :);

rot_mat =  eul2rotm(FitEllipsoid(7:9))

Fit = (rot_mat * inside_points')';
subplot(1,2,1);
plot3(ptFit(:,1),ptFit(:,2),ptFit(:,3),'r.');
hold on;
plot3(Fit(:,1),Fit(:,2),Fit(:,3),'b.');
%rotate([X, Y, Z],"rotmat", eul2rotm(FitEllipsoid(7:9)))

% subplot(1,1,1);
% hold off;
% plot3(ptFit(:,1),ptFit(:,2),ptFit(:,3),'r.');
% hold on;
% plot3(Pp(:,1),Pp(:,2),Pp(:,3),'b.');

%% IOU

%Fit = ptFit;
pred_size = size(Fit)
count = 0
ls = []
for cc = 1:pred_size(1,1)
    ptt =  real(Fit(cc, 1:3));
    if isPointInsideEllipsoid(ptt, centerr, semiaxiss, rott)
        count = count + 1;
        ls = [ls;ptt];
    end
end
hold on;

plot3(ls(:,1),ls(:,2),ls(:,3),'g*');
%plot3(pred_ellip(:,1),pred_ellip(:,2),pred_ellip(:,3),'b*');
count


v_pred = (4.0/3.0)*pi*FitEllipsoid(4)*FitEllipsoid(5)*FitEllipsoid(6)

v_orig = (4.0/3.0)*pi*semiaxiss(1)*semiaxiss(2)*semiaxiss(3)


v_intersect = min(v_pred, v_orig) * count / pred_size(1,1)

IoU =  v_intersect / (v_orig + v_pred - v_intersect)

toc