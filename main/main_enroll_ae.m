% main_enroll_ae.m 
% This script handles the authentication engine (AE) side
% of the enrollment phase. It receives the biometric features from the user
% device (UD), estimates the user's feature probability density function
% (PDF), evaluates the biometric information, generates an invariant
% feature mask, creates a random matrix for BioHashing, generates a random
% key for the new user, and finally creates a fuzzy commitment. It also
% transmits the random matrix for BioHashing back to the UD.