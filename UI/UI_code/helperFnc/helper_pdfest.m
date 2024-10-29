function [emppdf,pts] = helper_pdfest(feat)
% % quantization: eaual intervals
numfeat = size(feat,2);
numpts = 200;

% std normal distr axis
pdf_axis = linspace(-4,4,numpts);
pts = repmat(pdf_axis',1,numfeat);
delta = (4+4)/200;

% empirical density
emppdf = zeros(numpts,numfeat);
for i = 1:numfeat
    emppdf(:,i) = ksdensity(feat(:,i),pts(:,i));
end
emppdf = emppdf .* delta;


end