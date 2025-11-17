# Fuzzy System for PM2.5 Adjustment with Rule Reduction

This repository implements an **Adaptive Neuro-Fuzzy Inference System (ANFIS)** for adjusting low-cost sensor PM2.5 measurements, with explainable AI techniques for rule reduction and optimization.

## Overview

Low-cost (LC) air quality sensors often provide inaccurate measurements due to environmental factors such as hygroscopicity. This project uses ANFIS to calibrate and adjust PM2.5 concentration readings from LC sensors, while maintaining model interpretability through systematic rule reduction techniques.

## Key Features

- **ANFIS-based PM2.5 adjustment** with configurable membership functions
- **Binary Activation Method (BAM)** for rule usage analysis
- **Weighted Activation Method (WAM)** for strength-based rule evaluation
- **Automated rule pruning** with performance tracking
- **Hyperparameter tuning** for optimal rule reduction
- **Comprehensive visualization** of model performance and rule usage

## Research Background

This implementation is based on two research papers:

### 1. Initial ANFIS Model Development
**Casari, M., Kowalski, P. A., & Po, L. (2024)**  
*Optimisation of the adaptive neuro-fuzzy inference system for adjusting low-cost sensors PM concentrations*  
Ecological Informatics, 83, 102781.  
[https://doi.org/10.1016/j.ecoinf.2024.102781](https://doi.org/10.1016/j.ecoinf.2024.102781)

**Key Contributions:**
- Demonstrates ANFIS superiority over traditional ML methods (Linear Regression, Decision Trees, Random Forest, SVR, MLP)
- Optimal feature set: PM2.5, relative humidity, and temperature
- Enhanced interpretability through linguistic variables and fuzzy rules

### 2. Explainable AI for Rule Reduction
**Kowalski, P. A., Casari, M., & Po, L. (2026)**  
*Explainable AI for rule reduction in fuzzy models for air pollution measurement adjustment*  
Environmental Modelling & Software, 195, 106734.  
[https://doi.org/10.1016/j.envsoft.2025.106734](https://doi.org/10.1016/j.envsoft.2025.106734)

**Key Contributions:**
- Binary and Weighted Activation Methods for rule analysis
- Average Pearson correlation and MAE maintained after pruning
- Validated across multiple geographic locations

## Project Structure

```
.
├── call_fuzzy.mlx                                      # Main workflow file
├── preprocess.m                                        # Data preprocessing
├── evalFuzzySystem.m                                   # Model evaluation
├── runBinaryActivationMethod.m                         # Binary activation analysis
├── runWeightedActivationMethod.m                       # Weighted activation analysis
├── evaluateRulesReduction.m                            # Rule reduction evaluation
├── evaluateRulesReductionWithTuning.m                  # Hyperparameter-tuned reduction
├── evaluateRulesReductionWithSpecificNumberOfRules.m   # Fixed rule count evaluation
├── visualizeResults.m                                  # Rule usage visualization
└── visualizeRulesReduction.m                           # Performance metrics visualization
```

## Usage

Before running the system, ensure your data is imported into the MATLAB workspace with the following structure:

**Required Variables:**
- `train_dataset` - Training dataset (table or matrix)
- `test_dataset` - Testing dataset (table or matrix)

**Expected Columns:**
The datasets must contain the following columns:

| Column Name | Description | Unit | Type |
|-------------|-------------|------|------|
| `pm2p5_x` | Raw PM2.5 measurement from sensor | μg/m³ | Input |
| `pm2p5_y` | Reference PM2.5 measurement (ground truth) | μg/m³ | Output/Target |
| `relative_humidity` | Relative humidity | % | Input |
| `temperature` | Air temperature | °C | Input |
| `pressure` | Atmospheric pressure | hPa | Input |

**Data Format:**
- Data should be in MATLAB table format with column headers matching the names above
- Each row represents a single measurement/observation
- Ensure no missing values or use preprocessing to handle them
- Split your data into training and testing sets before importing

## Requirements

- MATLAB R2019b or later
- Fuzzy Logic Toolbox
- Statistics and Machine Learning Toolbox

## License

MIT License

## Contact

For questions or collaborations:
- Piotr A. Kowalski: pkowal@agh.edu.pl  (Professor AGH - Faculty of Physics and Applied Computer Science, AGH University of Krakow)
- Laura Po: laura.po@unimore.it (Associate Professor in Computer Science - Department of Engineering “Enzo Ferrari”, University of Modena and Reggio Emili UNIMORE)
- Martina Casari: martina.casari@unimore.it (Researcher - Associate Professor in Computer Science - Department of Engineering “Enzo Ferrari”, University of Modena and Reggio Emili UNIMORE)

## Acknowledgments
This work was conducted as part of the AIQS project (AI-enhanced Air Quality Sensor for Optimizing Green Routes), under the project code \texttt{DIP\_AIQS\_\-PO\_2025\_PNRR\_ECOS\_SK4AF\_E93C22001100001}.  
AIQS was funded through a closed call within the initiative "Ecosystem for Sustainable Transition in Emilia-Romagna" (ECOSISTER), financed under the National Recovery and Resilience Plan (PNRR) – Mission 4 “Education and Research”, Component 2 “From Research to Business”, Investment 1.5 “Creation and strengthening of innovation ecosystems, building territorial R\&D leaders” – funded by the European Union – *NextGenerationEU* (Grant Agreement No. 0001052, dated 23/06/2022 – Project ECS\_00000033 – CUP E93C22001100001).

In addition, this work was partially supported by the “Excellence Initiative – Research University” program at AGH University of Krakow and by a grant for statutory activity from the Faculty of Physics and Applied Computer Science of AGH.

We gratefully acknowledge the Regional Agency for Environmental Protection of the Aosta Valley, Arpae Emilia-Romagna, and the Provincial Agency for Environmental Protection of Trento for providing data from their reference monitoring stations. These stations were co-located with low-cost sensors donated by Wiseair Srl, whose contribution of sensors is also sincerely appreciated.
