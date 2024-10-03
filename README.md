# Model Testing Suite
A generalized and effective framework for model fitting and model comparison. This structure can be particularly useful when you are experimenting multiple models.

## Introduction
This section provides examples of how to perform model recovery, or more simply, run `model_recovery.m`. 
We use psychometric functions of a ternary temporal-order-judgment task to demonstrate model recovery. In this task, participants were presented with an audiovisual stimulus pair with varying stimulus-onset-asynchrony, and reported the perceived order (“visual first,” “auditory first,” or “simultaneous”). In this example, we compare two models, assuming the measurement distribution is either Gaussian or double-exponential.

## Usage

1. **Define Your Model**: In each folder, define your model, including its likelihood and simulation. Ensure that the `nll_[folder name]` is consistent with the folder name.
2. **Adapt the Template**: Modify `model_recovery_template` to include the models you want to compare and the ground-truth parameters.
3. **Update Parameter Samples**: Modify `generate_param_samples.m` to incorporate all the model parameters you are using.
4. **Run the Process**: Execute the model recovery scripts. The saved `.mat` file will contain everything needed to plot the recovery results.

## Prerequisite
- **BADS**: model fitting tool by Maximum Likelihood Estimation.

## Contact
For any questions or issues, please contact luhe.li@nyu.edu.