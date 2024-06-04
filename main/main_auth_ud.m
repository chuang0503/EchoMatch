% main_auth_ud.m 
% This script manages the user device (UD) side of the
% authentication phase. It captures a new biometric data point from the
% user, performs feature extraction, and applies BioHashing to generate a
% hashcode. The hashcode and the claimed identity are then sent to the
% authentication engine (AE) for verification.