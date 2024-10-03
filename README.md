# Model Playground
A flexible and effective framework for model fitting and model comparison. This structure might come in handy when you are experimenting with multiple models.

## Introduction
This project provides examples of how to perform model recovery. To see an example, run `model_recovery.m`.
Here, we compare psychometric functions of a ternary temporal-order-judgment task from a [paper](https://elifesciences.org/reviewed-preprints/97765) to demonstrate model recovery. In this task, participants were presented with an audiovisual stimulus pair with varying stimulus-onset-asynchrony, and reported the perceived order (“visual first,” “auditory first,” or “simultaneous”). In this example, we compare two models, assuming the measurement distribution is either Gaussian or double-exponential.
Will add some basic plots and parameter recovery later.

## Usage

1. **Define your model**: In each folder, define your model, including its likelihood and simulation. Ensure that the `nll_[folder name]` is consistent with the folder name.
2. **Adapt the recovery template**: Modify `model_recovery_template` to include the models you want to compare and the ground-truth parameters.
3. **Update parameter samples**: Modify `generate_param_samples.m` to incorporate all the model parameters you are using.
4. **Run!**: The saved `.mat` file will contain everything needed to plot the recovery results.

## Prerequisite
- **[BADS](https://github.com/acerbilab/bads)**: model fitting tool by Maximum Likelihood Estimation. Feel free to use the tool you prefer.

## Contact
For any questions or issues, please contact luhe.li@nyu.edu.
