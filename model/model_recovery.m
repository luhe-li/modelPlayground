clear; close all; clc;

%% knobs

check_fake_data = false; % check the simulated data before fitting
n_sample = 10; % number of ground-truth samples to generate

%% specify models

rng('shuffle');
specifications = {'Gaussian','Exponential'}; % official model names for plotting
folders = {'gauss','exp'}; % short names for folders
n_model = numel(specifications);
model_info = table((1:n_model)', specifications', folders', 'VariableNames', {'Number', 'Specification', 'FolderName'});

%% manage paths

[project_dir, ~]= fileparts(pwd);
[git_dir, ~] = fileparts(project_dir);
addpath(genpath(fullfile(project_dir, 'data')));
addpath(genpath(fullfile(project_dir, 'utils')));
addpath(genpath(fullfile(git_dir, 'bads'))); % add optimization tool, here we use BADS for example
out_dir = fullfile(pwd, mfilename); % output will have the same name as this script
if ~exist(out_dir, 'dir'); mkdir(out_dir); end

%% set up model

model.n_run = 3; % number of fits for each model
model.n_trial = 50; % number of trial for each condition
model.test_soa = -500:100:500; % x-axis where psychometric function is defined

%% sample ground truth parameters

for sim_m = 1:n_model

    sim_str = folders{sim_m};
    sim_func = str2func(['nll_' sim_str]);
    addpath(genpath(fullfile(pwd, sim_str)));

    model.mode = 'initialize';
    val = sim_func([], model, []);

    % set up the ground truth
    % 1. If you already have the data and fit them, you can use the
    %    group-level best parameters as the mean/sd of the ground-truth samples
    % 2. If you don't have the data yet, you can arbituarily set the 
    %    mean/sd of the ground-truth samples, though it can be suboptimal

    % sample 100 ground truth
    mu_gt = {[50, 60, 10, 0.01], [50, 30, 60, 10, 0.01]}; % number of parameters can vary by model
    sd_gt = {[10, 5, 5, 1e-4], [10, 5, 10, 5, 1e-4]};
    gt_samples = generate_param_samples(val, mu_gt{sim_m}, sd_gt{sim_m}, n_sample);

    % simulate model predictions for each ground-truth sample
    model.mode = 'predict';
    for i_sample = 1:n_sample
        temp_data = sim_func(gt_samples(:, i_sample), model, []);
        sim_data(sim_m, i_sample).data = temp_data;
        sim_data(sim_m, i_sample).gt = gt_samples(:, i_sample);
        sim_data(sim_m, i_sample).mu_gt = mu_gt{sim_m};
        sim_data(sim_m, i_sample).sd_gt = sd_gt{sim_m};
    end
    rmpath(genpath(fullfile(pwd, sim_str)));
end

%% check the simulated data before fitting if you haven't done so
% Skip if you are confident about the parameter and the fake data

if check_fake_data
    for sim_m = 1:n_model
        for i_sample = 1%:n_sample
            figure; hold on
            plot(sim_data(sim_m, i_sample).data.nT_A1st);
            plot(sim_data(sim_m, i_sample).data.nT_V1st);
            plot(sim_data(sim_m, i_sample).data.nT_simul);
            title(['Model ' num2str(sim_m) ' Sample ' num2str(i_sample)]);
        end
    end
end

%% fit by all models

for sim_m = 1:n_model

    for i_sample = 1:n_sample

        for fit_m = 1:n_model
            
            i_data = sim_data(sim_m, i_sample).data;
            fit_str = folders{fit_m};
            addpath(genpath(fullfile(pwd, fit_str)));
            curr_model = str2func(['nll_' fit_str]);

            model.mode = 'initialize';
            val = curr_model([], model, []);
            model.init_val = val;

            model.mode = 'optimize';
            llfun = @(x) curr_model(x, model, i_data);
            fprintf('[%s] Start sim model-%s, fit model-%s, recovery sample-%i \n', mfilename, folders{sim_m}, fit_str, i_sample);

            % fit the model multiple times with different initial values
            est_p = nan(model.n_run, val.num_param);
            nll = nan(val.num_param);
            for i  = 1:model.n_run
                [est_p(i,:), nll(i)] = bads(llfun,...
                    val.init(i,:), val.lb, val.ub, val.plb, val.pub);
            end

            % find the best fits across runs
            [min_nll, best_idx] = min(nll);
            best_p = est_p(best_idx, :);
            fits(sim_m, fit_m, i_sample).best_p = best_p;
            fits(sim_m, fit_m, i_sample).min_nll = min_nll;

        end

        % find the best fitting model for this sampled dataset
        [~, best_fit_m] = min([fits(sim_m, :, i_sample).min_nll]);
        cm(sim_m, i_sample) = best_fit_m;

    end

end

% save full results
fprintf('[%s] Model recovery done! Saving full results.\n', mfilename);
save(fullfile(out_dir, flnm), 'sim_data','fits','cm');