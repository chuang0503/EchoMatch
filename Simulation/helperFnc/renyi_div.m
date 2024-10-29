% taking probability column vectors as input, make sure sum over column
% equals 1. alpha is the renyi alpha parameter.

function divergence = renyi_div(user_prob, pop_prob, alpha)

numpts = size(user_prob,1);
numfeats = size(user_prob,2);

assert(size(pop_prob,1)==numpts);
assert(size(pop_prob,2)==numfeats);

divergence = zeros(1,numfeats);

for i = 1:numfeats
    P = user_prob(:,i);
    Q = pop_prob(:,i);

    % calculate renyi alpha divergence
   if alpha == 0
        % Handling for alpha = 0
        D = -log2(sum(Q(P > 0))+eps);
    elseif alpha == 1
        % Handling for alpha = 1 (KL divergence)
        D = sum(P(P > 0) .* log2(P(P > 0) ./ Q(P > 0)));
    elseif isfinite(alpha)
        % For alpha > 1, use the general formula
        D = (1 / (alpha - 1)) * log2(sum((P.^alpha) .* (Q.^(1-alpha))));
    elseif isinf(alpha)
        % Handling for alpha approaching infinity
        D = max(log2(P ./ Q));
    else
        error('Alpha must be 0, positive, or infinity');
    end

    % Replace NaN and Inf with appropriate values
    if isnan(D)
        D = 0; % If the result is NaN, set to 0 (interpretation needed based on context)
    elseif isinf(D)
        D = Inf; % Retain Inf as it indicates division by 0 or log2(0)
    end

    divergence(i) = D;
end
end