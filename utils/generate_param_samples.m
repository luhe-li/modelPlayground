function samples = generate_param_samples(Val, mean_values, sd_values, num_sample)
% generate samples of parameter sets given the mean and sd of group
% parameter estimates from model fitting for all models.

% extract the parameter IDs
param_ids = Val.param_id;

% initialize the samples matrix
num_parameters = length(param_ids);
samples = zeros(num_parameters, num_sample);

% loop through each parameter
for i = 1:num_parameters
    param_id = param_ids{i};

    switch param_id

        % for unbounded parameters
        case {'\tau','\mu','\lambda'}
            param_samples = normrnd(mean_values(i), sd_values(i), [1, num_sample]);

        % for bounded parameters that are positive
        case {'\sigma_{A}', '\sigma_{V}', '\sigma', 'criterion'}
            v = sd_values(i).^2;
            log_mu = log((mean_values(i).^2) ./ sqrt(v + mean_values(i).^2));
            log_sigma = sqrt(log(v ./ (mean_values(i).^2) + 1));
            param_samples = lognrnd(log_mu, log_sigma, [1, num_sample]);
        otherwise
            error('Unknown parameter ID: %s', param_id);
    end

    % ensure all samples are within the bounds
    for j = 1:num_sample
        while param_samples(j) < Val.lb(i) || param_samples(j) > Val.ub(i)
            switch param_id
                case {'\tau','\mu','\lambda'}
                    param_samples(j) = normrnd(mean_values(i), sd_values(i));

                case {'\sigma_{A}', '\sigma_{V}', '\sigma', 'criterion'}
                    param_samples(j) = lognrnd(log_mu, log_sigma);
                otherwise
                    error('Unknown parameter ID: %s', param_id);
            end
        end
    end

    samples(i,:) = param_samples;
end

end
