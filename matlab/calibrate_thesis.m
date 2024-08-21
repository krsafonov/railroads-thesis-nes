fname = 'data.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);

s = val.s + 1;
t = val.t + 1;

s = s.';
t = t.';
pop = val.pop;
prod = val.prod;

G = graph(s, t);
A = adjacency(G);
A = full(A);

param = init_parameters('LaborMobility','off','K',1,'gamma',1,'beta',1,'N',1,'Annealing','off','ADiGator','off');

[param, g]=create_graph(param,[], [], 'Type','custom', 'Adjacency', A, 'X', val.X, 'Y', val.Y);

param.Lj= pop / max(pop);
param.Zjn= prod / max(prod)+0.01;

%% Plot the mesh
s='simple_geography_mesh_population';
fig=figure('Units','inches','Position',[0,0,7.5,7.5],'Name',s);
set(gcf,'PaperUnits',get(gcf,'Units'),'PaperPosition',get(gcf,'Position')+[-.25 2.5 0 0]);
plot_graph(param,g,[],'Edges','off','Mesh','on','MeshColor',[.2 .4 .6]);
box off;
axis off;

tic;

% parameters that remain constant throughout the loop across calibrations
alpha = 0.4;
beta = 1;
sigma = 5;
rho = 0;
a = 1;
Ngoods = 5;  % for 'largest ciies', this is the number of goods
              % for 'nuts', the number of goods is the min between Ngoods
              % and the number of NUTS regions, but the file is loaded with
              % the name Ngoods=10
nu = 1;

% countries
country_icc = 'RUS';
country = 'RUS';

% set parameters to be run in the loop
gamma = 0.13/0.10 *beta;
cong = 'on';
mobil = 'off';

% baseline parameters
param_2 = init_parameters( 'a',a,'rho',rho,'alpha',alpha,'sigma',sigma,...       % preferences and technology
                         'beta',beta,'gamma',gamma,'nu',nu,'m',ones(Ngoods+1,1),...   % transpot costs
                         'K',1,...
                         'LaborMobility',char(mobil),...
                         'N',Ngoods+1,...
                         'CrossGoodCongestion',char(cong),...
                         'TolKappa',1e-4 );

% define file to load calibration and set diary
filename = [ country,...
            '_a',num2str( param_2.a ),...
            '_rho',num2str( param_2.rho ),...
            '_alpha',num2str( param_2.alpha ),...
            '_sigma',num2str( param_2.sigma ),...
            '_beta',num2str( param_2.beta ),...
            '_gamma',num2str( param_2.gamma ),...
            '_nu',num2str( param_2.nu ),...
            '_mobil',num2str( param_2.mobility ),...
            '_cong',num2str( param_2.cong ),...
            '_ngoods',num2str( Ngoods )];

path_save_calibrations = '';
load( [ 'RUS_a1_rho0_alpha0.4_sigma5_beta0.13_gamma0.1_nu1_mobil0_cong1_ngoods3_calib.mat' ] );   % this loads the structure calibration

param.Lj = calibration.param.Lj;
param.N = Ngoods+1;
param.Zjn = calibration.param.Zjn;

param.MAX_ITER_KAPPA = 1;

%param.a = a;
%param.rho = rho;
param.beta = beta;
param.alpha = alpha;
param.gamma = gamma;

%% Test Zjn
param.Zjn(:,1:param.N-1)=0; % default locations cannot produce goods 1-10
param.Zjn(:,param.N)=1; % but they can all produce good 11 (agricultural)

% Draw the cities randomly
% rng(5); % reinit random number generator
for i=1:param.N-1
    newdraw=false;
    while newdraw==false
        j=round(1+rand()*(g.J-1));
        if any(param.Zjn(j,1:param.N-1)>0)==0 % make sure node j does not produce any differentiated good
            newdraw=true;
            param.Zjn(j,1:param.N)=0;
            param.Zjn(j,i)=1;
        end
    end
end

param.Zjn = calibration.param.Zjn;

%% Optimization
res(1)=optimal_network(param, calibration.g);
% param = init_parameters('param',param,'gamma',2); % change only gamma, keep other parameters
% res(2)=optimal_network(param,g);
% res(3)=annealing(param,g,res(1).Ijk); % improve with annealing, starting from previous result

results=res(1);
sizes=4*results.Cj/max(results.Cj);
shades=results.Cj/max(results.Cj);
plot_graph(param,g,results.Ijk,'Sizes',sizes,'Shades',results.Cj/max(results.Cj),...
    'NodeFgColor',[1 .9 .4],'NodeBgColor',[.8 .1 .0],'NodeOuterColor',[0 .5 .6],...
    'EdgeColor',[0 .4 .8],'MaxEdgeThickness',4);

save( [ 'results.mat' ],'results' );