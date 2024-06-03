# EchoMatch: Ear Authentication using Template-Matching

This live script demonstrates a non-machine learning approach using ear canal reflections for user authentication. The main idea is to evaluate the biometric information, i.e., Renyi divergence between the distribution of new user and gallery dataset, and then select the most discriminative feature subsets to generate the biometric template.

During authentication, the new biometric data will be compared with the enrolled biometric template. In order to reduce the computational and storage overhead, we propose to use BioHashing that converts the raw representation into a fixed-length binary array. Next, a Fuzzy Commitment scheme with Error-Correction Code is employed for template protection, which is rarely mentioned in classifier-based ear authentications.

## Overall Framework

### Entities

1. **Authentication Engine (AE)**
   - The authentication engine stores the gallery data, which is assumed to be safely used for development.
   - During enrollment, the authentication engine receives the new user's biometric data (features) and creates a secure template, which reveals no original biometric data.
   - Additionally, user-specific data, in this design, feature masks, will be stored to improve authentication performance.
   - A quality control module will reject users due to low data quality or uniqueness (not included in this simulation).
   - All data is stored at a secure location.

2. **User Device (UD)**
   - The user device initiates and captures the ear canal response, which is the raw biometric sample in this study.
   - Feature extraction is performed here to reduce communication overhead with the authentication engine.
   - Those features will be discarded immediately once used to protect biometric security and privacy.
   - BioHashing is done locally, and the hashcode is transmitted to the AE.

3. **Secure Communication between AE and UD**
   - It is assumed that all sensitive data is encrypted if necessary. Performance is still evaluated under potential attacks.

## Authentication Process

### 1. Development Phase
- Collect gallery dataset
- Perform feature extraction
- Estimate feature PDF

### 2. Enrollment Phase
- **UD**: Capture raw sample batch, perform feature extraction.
- **UD => AE**: Transmit biometric features.
- **AE**: 
    - Estimate user feature PDF
    - Evaluate biometric information
    - Generate invariant feature mask
    - Generate random matrix for BioHashing
    - Create a random key for the new user
    - Generate fuzzy commitment
- **AE => UD**: Transmit random matrix for BioHashing.

### 3. Authentication Phase
- **UD**: Capture new biometric data, perform feature extraction, apply BioHashing.
- **UD => AE**: Transmit hashcode and claimed identity.
- **AE**:
    - Apply the hashcode to the fuzzy commitment
    - Compare the stored key
    - Make a decision
- **AE => UD**: Transmit the decision.

## Code Structure

### UI
- To be adapted from old files

### Config
- Set parameters

### Helper Functions
- Contained in the `helperFnc` folder

### Data
- Stored in the `data` folder

### Main Scripts
- `main_develop.m`: Process the gallery data
- `main_enroll_ud.m`
- `main_enroll_ae.m`
- `main_auth_ud.m`
- `main_auth_ae.m`
- `main_update.m`: Optional, update the gallery dataset
- `simulation_data_split.m`: Split the data for simulation
- `analysis.m`: Feature representation, bioInfo, hashcode
- `evaluation_efficiency.m`
- `evaluation_accuracy.m`
- `evaluation_security.m`
- `evaluation_robustness.m`
