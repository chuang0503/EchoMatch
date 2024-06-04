% main_auth_ae.m 
% This script deals with the authentication engine (AE) side
% of the authentication phase. It receives the hashcode and claimed
% identity from the user device (UD), applies the hashcode to the fuzzy
% commitment, compares it with the stored key, and makes an authentication
% decision. The decision is then transmitted back to the UD.