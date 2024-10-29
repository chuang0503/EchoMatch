function [sdiv, mask] = helper_biofeatmask(pdf1, pdf2,alpha)
% kl divergence
user_divergence = renyi_div(pdf1, pdf2, alpha);
mask = imbinarize(rescale(user_divergence));

sdiv = sum(user_divergence .* mask,'all');
end