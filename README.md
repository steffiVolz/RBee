# RBee 🐝

## RetinoBlastoma boosted ensemble estimator

*DNA Methylation Array-Based Molecular Classification of Retinoblastoma*

**RBee** is an R package providing a pretrained XGBoost classifier for molecular classification of retinoblastoma using DNA methylation array beta values.

The classifier distinguishes five molecular classes:

- **Subtype1** — Retinoblastoma Subtype 1
- **Subtype2_ClusterB** — Retinoblastoma Subtype 2, Cluster B
- **Subtype2_ClusterC** — Retinoblastoma Subtype 2, Cluster C
- **NormalRetina** — Normal retinal tissue
- **DiseaseControl** — Non-retinoblastoma ocular disease controls

RBee supports classification of preprocessed methylation profiles from both tumor tissue and aqueous humor (AH) liquid biopsies.

## Installation

RBee is available on [GitHub](https://github.com/steffiVolz/RBee) and is currently being prepared for submission to CRAN.

To install RBee directly from GitHub:

```r
install.packages("remotes")
remotes::install_github("steffiVolz/RBee")
```

Alternatively, RBee can be installed using Git:

```r
remotes::install_git("https://github.com/steffiVolz/RBee.git")
```

## Input Data

RBee requires a numeric matrix or data frame containing DNA methylation beta values.

- **Rows:** CpG probe identifiers
- **Columns:** Sample identifiers
- **Values:** DNA methylation beta values between 0 and 1

Input data must be preprocessed before classification.

The classifier was trained on methylation array data normalized using `minfi::preprocessNoob()` separately for each batch.

RBee does not perform background correction, normalization, or other methylation preprocessing.

The pretrained model uses 8,999 CpG features. Missing CpGs are represented as `NA` and handled natively by XGBoost. The impact of missing features on prediction reliability must be considered.

## Usage

RBee provides a synthetic DNA methylation beta matrix containing 8,999 CpG features and three artificial samples for demonstrating the classification workflow.

```r
library(RBee)

# Load synthetic example data
data("beta_example")

# Run classification
results <- predict_retinoblastoma(
  beta_example,
  verbose = TRUE
)

# Display predictions and class probabilities
print(results)
```

The classifier returns a data frame containing:

- `Sample`: Sample identifier.
- `Prediction`: Predicted molecular subtype or control class.
- `MaxProbability`: Highest predicted class probability.
- `Subtype1`, `Subtype2_ClusterB`, `Subtype2_ClusterC`, `NormalRetina`, `DiseaseControl`: Individual class probabilities.

To suppress the ASCII bee and console messages:

```r
results <- predict_retinoblastoma(
  beta_example,
  verbose = FALSE
)
```

### Using Your Own Methylation Data

RBee accepts a numeric matrix or data frame containing preprocessed DNA methylation beta values, with CpG identifiers as row names and sample identifiers as column names.

```r
# beta_matrix contains preprocessed methylation beta values
results <- predict_retinoblastoma(
  beta_matrix,
  verbose = TRUE
)
```

The classifier automatically matches CpG identifiers to the 8,999 required model features and restores the original training feature order.

Missing CpGs are represented as `NA` and handled natively by XGBoost. A warning is displayed when required features are absent.

**Note:** The included example data are randomly generated and intended solely for demonstrating package functionality. Predictions from these synthetic samples have no biological interpretation.

## Model Development

The XGBoost classifier was trained on 114 DNA methylation profiles comprising retinoblastoma tumor tissue and aqueous humor (AH) liquid biopsy samples, as well as normal retina and ocular disease controls.

To enable molecular classification independent of sample type, CpG sites exhibiting significant differential methylation between matched retinoblastoma tumor tissue and AH samples were identified using paired differential methylation analysis with limma and excluded from classifier feature selection. This strategy was designed to minimize tissue-specific biases and ensure that classification is primarily driven by disease-associated methylation signatures rather than differences between tumor tissue and AH.

Following variance filtering and one-versus-rest feature selection, the final classifier was trained on 8,999 CpG features using XGBoost.

Model performance was evaluated using stratified five-fold cross-validation and independently validated on an external cohort of 63 retinoblastoma samples.

## Intended Use

RBee is provided for research use. Classification results should not be used as the sole basis for clinical diagnosis or treatment decisions.


## Citation

If you use RBee in your research, please cite the associated preprint:

Volz, S., Montigel, S. H., Ryl, T., et al. (2026).
*Aqueous Humor Liquid Biopsy Enables Multi-Omics Tumor Profiling and Methylation-Based Machine-Learning Stratification of Retinoblastoma.*

Preprint.

DOI: https://doi.org/10.64898/2026.07.09.26357661

For citation information within R, use:

```r
citation("RBee")
```

The citation will be updated following publication of the peer-reviewed manuscript.

## License

RBee is licensed under the GNU General Public License version 3 (GPL-3).

See the [GNU GPL-3 license](https://www.gnu.org/licenses/gpl-3.0.html) for details.
