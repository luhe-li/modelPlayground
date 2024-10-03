function out = nll_exp(free_param, model, data)

if strcmp(model.mode, 'initialize')

    out.param_id = {'\tau','\sigma_{A}','\sigma_{V}','criterion','\lambda'};
    out.num_param = length(out.param_id);

    % hard bounds, the range for lb, ub, larger than soft bounds
    param_h.tau = [-300, 300]; % ms
    param_h.sigma_a = [0.01, 300]; % ms
    param_h.sigma_v = [0.01, 300]; % ms
    param_h.c = [0.01, 350]; % ms
    param_h.lambda = [1e-4, 0.06]; % percentage

    % soft bounds, the range for plb, pub
    param_s.tau = [-100, 100]; % ms
    param_s.sigma_a = [10, 100]; % ms
    param_s.sigma_v = [10, 100]; % ms
    param_s.c = [1, 100]; % ms
    param_s.lambda = [0.01, 0.03]; % percentage

    % reorganize parameter bounds to feed to bads
    fields = fieldnames(param_h);
    for k = 1:numel(fields)
        out.lb(:,k) = param_h.(fields{k})(1);
        out.ub(:,k) = param_h.(fields{k})(2);
        out.plb(:,k) = param_s.(fields{k})(1);
        out.pub(:,k) = param_s.(fields{k})(2);
    end
    model.param_s = param_s; 
    model.param_h = param_h;

    % get grid initializations
    num_sections = model.n_run;
    out.init = getInit(out.lb, out.ub, num_sections, model.n_run);

else
    
    % assign free parameters
    tau = free_param(1);
    sigma_a = free_param(2);
    sigma_v = free_param(3);
    c = free_param(4);
    lambda = free_param(5);

    if strcmp(model.mode, 'optimize')
        % calculate probabilities
        [p_a_first, p_simul, p_v_first] = pmf_exp(model.test_soa, tau, sigma_a, sigma_v, c, lambda);

        % calculate negative log likelihood
        nll = data.nT_A1st * log(p_a_first)' + data.nT_V1st * log(p_v_first)' + data.nT_simul * log(p_simul)';
        out = nll;

    elseif strcmp(model.mode, 'predict')
        % calculate probabilities
        [p_a_first, ~, p_v_first] = pmf_exp(model.test_soa, tau, sigma_a, sigma_v, c, lambda);

        n_trials = model.n_trial; % number of trials
        n_levels = length(model.test_soa); % number of soa levels

        % generate random matrix for predictions
        rand_matrix = rand(n_trials, n_levels);
        bool_v_first = rand_matrix < repmat(p_v_first, [n_trials, 1]);
        bool_a_first = rand_matrix > repmat(1 - p_a_first, [n_trials, 1]);

        % count responses
        out.nT_V1st = sum(bool_v_first, 1);
        out.nT_A1st = sum(bool_a_first, 1);
        out.nT_simul = n_trials - out.nT_A1st - out.nT_V1st;

        % calculate response probabilities
        out.p_resp(1,:) = out.nT_V1st / n_trials;
        out.p_resp(3,:) = out.nT_A1st / n_trials;
        out.p_resp(2,:) = out.nT_simul / n_trials;
    end
end

end

function [p_afirst_lapse, p_simul_lapse, p_vfirst_lapse] = pmf_exp(test_soa, tau, sigma_a, sigma_v, c, lambda)

p_afirst_lapse        = lambda/3 + (1-lambda).* expCDF(test_soa, tau, c, sigma_a, sigma_v);
p_vfirst_lapse        = lambda/3 + (1-lambda).* (1 - expCDF(test_soa, tau, c, sigma_a, sigma_v)); 
p_simul_lapse         = 1 - p_afirst_lapse - p_vfirst_lapse;

end

% CDF of double exponential distribution. % Eq.3 in García-Pérez & Alcalá-Quintana (2012)
function p_resp = expCDF(SOAs, tau, m, sigma_a, sigma_v)
    delta = m - SOAs - tau;
    p_resp = zeros(size(SOAs));
    p_resp(delta <= 0) = sigma_v / (sigma_a + sigma_v) .* exp(delta(delta <= 0) / sigma_v);
    p_resp(delta > 0) = 1 - sigma_a / (sigma_a + sigma_v) .* exp(-delta(delta > 0) / sigma_a);
    % ensure p_resp is within [0, 1]
    p_resp = max(min(p_resp, 1), 0);
end
