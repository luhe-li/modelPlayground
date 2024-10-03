function out = nll_template(free_param, model, data)

if strcmp(model.mode, 'initialize')

    % ----------------- set your parameters here -----------------
    out.param_id = {};
    out.num_param = length(out.param_id);

    % hard bounds, the range for lb, ub, larger than soft bounds
    param_h.x = [];

    % soft bounds, the range for plb, pub
    param_s.x = [];
    % ------------------------------------------------------------

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

    % ----------------- set your parameters here -----------------
    % assign free parameters
    [] = free_param(1);
    % ------------------------------------------------------------

    if strcmp(model.mode, 'optimize')

        % -------- set negative log likelihood function here ---------

        % ------------------------------------------------------------
        out = nll;

    elseif strcmp(model.mode, 'predict')

        % ---------------- model simulation here ---------------------

        % ------------------------------------------------------------
    end
end

end