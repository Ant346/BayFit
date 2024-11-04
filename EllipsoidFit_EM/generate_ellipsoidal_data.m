% function [Samples1,L]=generate_ellipsoidal_data(ell_par,type,num, gt, my_pt)
function [Samples1,L]=generate_ellipsoidal_data(type,num, std_n, gt, centerr, semiaxiss, rott)
%==========================================================================
% Generate ellipsoidal data points for fitting tests
% Method: First generate spherical points and then using the affine
% transformation to transform them as ellipsoidal points

% Input
%----------
% ell_par:  1x9  [Xc Yc Zc a b c alpha beta gamma]   ellipsoidal parameters;
% type:     0    without outliers; 
%           1    with outliers.
% num:      the number of data points.
%
% Output:
%----------
% Samples:  Nx3 array   the generated ellipsoidal points
% L:        3x3 affine matrix
%%=========================================================================


% ellipsoidal points
center=centerr';
a=semiaxiss(1);
b=semiaxiss(2);
c=semiaxiss(3);
% alpha=ell_par(1,7);
% beta=ell_par(1,8);
% gamma=ell_par(1,9);

% scale matrix
A=diag([1/a^2,1/b^2,1/c^2]);

% % rotation matrix
% invRx=[1 0 0;
%     0 cos(-alpha) sin(-alpha);
%     0 -sin(-alpha) cos(-alpha);
% ];
% 
% invRy=[cos(-beta) 0 sin(-beta);
%     0 1 0;
%     -sin(-beta) 0 cos(-beta);
% ];
% 
% invRz=[cos(-gamma) sin(-gamma) 0;
%     -sin(-gamma) cos(-gamma) 0;
%     0 0 1;
% ];

% R=invRz*invRy*invRx;
R=rott;
M=R'*A*R;
[~, S, V] = svd(M);%LL'=M;
L= real(V' * diag(1./sqrt(diag(S))) * V);



Dimension=3;
NumSamples=num;


% Obtain random samples evenly distributed on the surface of the unit hypersphere
Samples=randn(Dimension,NumSamples);
SampleNorms=sqrt(sum(Samples.^2,1));
Samples=Samples./repmat(SampleNorms,[Dimension 1]); 


% Add some noise
Samples=Samples+0.05*randn(size(Samples));% noise: 0.01-0.05-0.1-0.15-0.2-0.25

% Transform the data into the desired ellipsoid
% Samples=L*Samples+repmat(center,[1 NumSamples]); 

%Samples = Samples(:, 1:60);
Outliers=[];
smpl =  Samples' ;
%smpl = my_pt;
if gt
    %Samples = my_pts;
    
    
    
    mean_smpl = mean(smpl);
%     std = ell_par(1,10);
    
    snr = mean_smpl/std_n;
        
    
    
    NumOut=0.7*num;
    if type

%         Ox = awgn(smpl(:,1),snr(1,1),'measured');
%         Oy = awgn(smpl(:,2),snr(1,2),'measured');
%         Oz = awgn(smpl(:,3),snr(1,3),'measured');
%         Outliers=[Ox,Oy,Oz];
%         smpl(:,1) = awgn(smpl(:,1),snr(1,1),'measured');
%         smpl(:,2) = awgn(smpl(:,2),snr(1,2),'measured');
%         smpl(:,3 )= awgn(smpl(:,3),snr(1,3),'measured');
        xn = randn(size(smpl(:,1)));
        smpl(:,1) = bsxfun(@plus, smpl(:,1), std_n*xn);
        yn = randn(size(smpl(:,2)));
        smpl(:,2) = bsxfun(@plus, smpl(:,2), std_n*yn);
        zn = randn(size(smpl(:,3)));
        smpl(:,3) = bsxfun(@plus, smpl(:,3), std_n*zn);
        Outliers = []
%         Outliers=[Ox,Oy,Oz];

    end
end
Samples1.sample=smpl;
Samples1.outlier=Outliers;

