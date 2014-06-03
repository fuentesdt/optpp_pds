% This script is meant to see how many datasets have solutions that are
% good. The following questions need to be answered:
% 1. Does a good solution exist? This will be done by doing max(dice) >0.7
% 2. How far (in mu_eff value) is the max Dice from the min obj fxn?
%              I.e. (mu_eff@maxDice - mu_eff@minObjFxn)
% 3. Where does the optimizer go? Ie (mu_eff@Opt - mu_eff@minObjFxn) and
%           (mu_eff@Opt - mu_eff@maxDice)
% 4. How does the maxDice depend on isotherm choice (temperature).

cd /FUS4/data2/sjfahrenholtz/gitMATLAB/opt_new_database/PlanningValidation
% load all_new_Tmp_files.mat
% 
% data.labels = total_path(:,1);
% 
% 
%
% num_runs = size(total_path,1);
% val_dice = zeros (num_runs,1);
% index_dice = val_dice;
% data.data = zeros (5001,6,num_runs);
% for ii=1:num_runs
%     data.data(:,:,ii) = total_path{ii,2};
% end

% Load the brute force sensitivity study
clear
close all

% I have the list of good runs, now I need to code it. 
% 
% The input: vector of paths to whatever interested datasets and vector of optimized mu_eff values.
% (I assume that the inverse problem is run before the LOOCV begins).
% 
% The process:
% Its iterative. Heres one iteration of leave-one-out cross validation (LOOCV). Average the optimized mu_eff for all but one ablation. 
% Use the averaged optimized mu_eff for the reserved ablation. 
% That means a dakota.in file will be written with the default constants and the averaged optimized mu_eff value.
% That dakota.in file wile be read by the BHTE code, the BHTE code runs, and a prediction is made. 
% Then, the prediction 57 deg_C isotherm is compared to the MRTI 57 dec_C isotherm using a Dice similarity coefficient (DSC). That is one iteration.
% Overall process iterates the LOOCV algorithm such that there are n possible iterations for n ablation datasets resulting in n DSC values. 
% The DSC values mean and variance are calculated. The mean and variance are sent to the t-test to find the hypotheses results.
% 
% The output: The output is a binary acceptance/rejection of the null and alternative hypotheses.

% This script finds the best mu_eff for the different studies.
MATLAB_on_off = 1; % 0 = off/false; 1 = on/true
opt_type = 'sanity_1D' ;


% Identify the studies to be examined.
Study_paths {1,1} = 'Study0035';
Study_paths {1,2} = '0530';
Study_paths {2,1} = 'Study0030';
Study_paths {2,2} = '0495';
Study_paths {3,1} = 'Study0030';
Study_paths {3,2} = '0497';
Study_paths {4,1} = 'Study0030';
Study_paths {4,2} = '0491';
Study_paths {5,1} = 'Study0030';
Study_paths {5,2} = '0496';
Study_paths {6,1} = 'Study0030';
Study_paths {6,2} = '0490';
Study_paths {7,1} = 'Study0017';
Study_paths {7,2} = '0378';
Study_paths {8,1} = 'Study0025';
Study_paths {8,2} = '0438';
Study_paths {9,1} = 'Study0025';
Study_paths {9,2} = '0435';
Study_paths {10,1} = 'Study0025';
Study_paths {10,2} = '0440';
Study_paths {11,1} = 'Study0025';
Study_paths {11,2} = '0436';
Study_paths {12,1} = 'Study0028';
Study_paths {12,2} = '0466';
Study_paths {13,1} = 'Study0028';
Study_paths {13,2} = '0468';
Study_paths {14,1} = 'Study0028';
Study_paths {14,2} = '0471';
Study_paths {15,1} = 'Study0026';
Study_paths {15,2} = '0447';
Study_paths {16,1} = 'Study0026';
Study_paths {16,2} = '0457';
Study_paths {17,1} = 'Study0026';
Study_paths {17,2} = '0455';
Study_paths {18,1} = 'Study0026';
Study_paths {18,2} = '0453';
Study_paths {19,1} = 'Study0026';
Study_paths {19,2} = '0450';
Study_paths {20,1} = 'Study0026';
Study_paths {20,2} = '0451';
Study_paths {21,1} = 'Study0022';
Study_paths {21,2} = '0418';
Study_paths {22,1} = 'Study0022';
Study_paths {22,2} = '0417';
Study_paths {23,1} = 'Study0021';
Study_paths {23,2} = '0409';
Study_paths {24,1} = 'Study0021';
Study_paths {24,2} = '0414';
Study_paths {25,1} = 'Study0021';
Study_paths {25,2} = '0415';

num_studies = size(Study_paths,1);
cell_data = csvimport('alt_datasummary.txt');
headers = cell_data(1,1:3);

for ii = 1:num_studies
    if  strcmp(strtrim(cell_data{ii,3}),'nan') == 1
        cell_data{ii,3} = ' 1.00000e+00';
    end
end
clear ii


for ii = 2:num_studies+1
    cell_data{ii,3} = str2num(cell_data{ii,3});
end
clear ii
mu_eff_data = cell2mat(cell_data(2:end,:));



matching_num = zeros(1,num_studies);
mu_eff_index = zeros(1,num_studies);
mu_eff_opt   = zeros(1,num_studies);
for ii = 1:num_studies
    matching_num(ii) = str2num(Study_paths{(ii),2});
    mu_eff_index(ii) = find( mu_eff_data(:,1) == matching_num(ii));
    mu_eff_opt(ii) = mu_eff_data(mu_eff_index(ii),2);
end
clear ii

mu_eff_opt22 = mu_eff_opt*(6000-100)+100;
dice_pre = 1 - mu_eff_data(:,3);
toss_index7 = find(dice_pre<0.7);
toss_index8 = find(dice_pre<0.8);

mu_eff7 = mu_eff_opt22;
mu_eff7 (toss_index7) = [];
mu_eff8 = mu_eff_opt22;
mu_eff8 (toss_index8) = [];

dice7 = dice_pre;
dice7(toss_index7) = [];
dice8 = dice_pre;
dice8(toss_index8) = [];

stats_pre = Descriptive_statistics(mu_eff_opt22);
stats7 = Descriptive_statistics(mu_eff7);
stats8 = Descriptive_statistics(mu_eff8);

stats_pre
stats7
stats8

% figure; hist(mu_eff_opt22);
% figure; hist(mu_eff7);
% figure; hist(mu_eff8);

[ hh_pre, dice_values_pre ] = LOOCV_t_test_DiceTemp ( Study_paths, mu_eff_opt22, opt_type );

% Remove Study_paths indices
temp_paths = Study_paths;
temp_paths(toss_index7,:) = [];
Study_paths7 = temp_paths;
temp_paths = Study_paths;
temp_paths(toss_index8,:) = [];
Study_paths8 = temp_paths;


[ hh7, dice_values7 ] = LOOCV_t_test_DiceTemp ( Study_paths7, mu_eff7, opt_type );
[ hh8, dice_values8 ] = LOOCV_t_test_DiceTemp ( Study_paths8, mu_eff8, opt_type );
mu_eff_iter = mu_eff8;
stats_iter = stats8;
paths_iter = Study_paths8;
hh_iter.ptest = 0.5;
stats_iter.n = 40;

while hh_iter.ptest > 0.05 && stats_iter.n > 3
    
    residual8 = abs( mu_eff_iter - stats_iter.mean ); % Find the largest residual
    [~,toss_index] = max( residual8 );
    temp_mu_eff = mu_eff_iter; % Toss the mu_eff value that is the largest residual
    temp_mu_eff(toss_index) = [];
    mu_eff_iter = temp_mu_eff;
    temp_paths = paths_iter; % Toss the path
    temp_paths(toss_index,:) = [];
    paths_iter = temp_paths;
    stats_iter = Descriptive_statistics( mu_eff_iter );
    Study_paths_iter = temp_paths;
    
    [ hh_iter, dice_values_iter ] = LOOCV_t_test_DiceTemp ( Study_paths_iter, mu_eff_iter, opt_type );

end

    
