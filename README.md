# SSD for Predictive Maintenance
## Authors
Research Project Group 13: Aurélien Bertrand, Bart van Gool, Abdulmuizz Khalak, Ronja Langrock, Juliette Maes.

## Background
Predictive maintenance is a proactive maintenance strategy that seeks to predict when failures are likely to occur in machinery to maintain it before any critical failures take place. Predictive maintenance aims to minimize the costs associated with both the downtime of machinery and undergoing major repair operations. This approach involves continual monitoring of machinery during use so that any deterioration that may lead to faults can be detected ahead of time. To monitor the machinery, various types of sensors are fitted which provide data on how different parts of the machines are operating. This data must then be analyzed to find signs of potential issues and degradation. The data from many of these sensors comes in the form of signals, and analyzing these signals for signs of faults is no trivial task. Although various techniques including machine learning and statistical modeling have already been applied, this project endeavours to discover the utility of Singular Spectrum Decomposition (SSD) within this domain

SSD is a decomposition method that decomposes non-linear and nonstationary signals into narrow-banded frequency components. By applying SSD to both real-world and synthetic datasets our research hopes to discover whether the acquired components can help identify signs of failure and give additional insight into the specific nature of the faults. Resulting decompositions will be studied both visually and through machine learning techniques to identify how and when SSD can be most useful in the predictive maintenance domain.

## Repository structure
- `_tests`: Includes all unit tests to ensure code integrity. After any modification to the code, please run the `run_tests.m` file to ensure everything works as intended.
- `app`: Includes the main application developed, you can open `SSDApp.mlapp` and enjoy it!
- `data_generation`: Includes both the simple and advanced data generators built throughout this project. There is a `demo` folder to showcase how to use the generators.
- `faults_classification`: Includes the different classification models built to classify faults in both the simple and advanced generators.
- `monitoring`: Includes sample files showcasing how to use the code to continuously monitor a signal. More information regarding the run configuration follows. Note: if you are unable to run `continuous_monitoring.m`, then refer to `continuous_monitoring_api.m` instead (you also need to start `server.py`, located in the root folder).
- `plotting`: Includes different files to plot raw signals,  components, etc.
- `singular_spectrum_decomposition`:  Includes code related to SSD decompositions, both the randomized and normal versions.
- `utils`: Includes files that are widely used in the repository.

## Run configuration
In order to run the code, several steps need to be undertaken.

### Python environment
In this project, we use an API to create a connection from MATLAB to Python. However, MATLAB only allows the use of Python 3.9 or earlier version.

It is best to create a virtual environment for this project. There are 2 possibilities:
#### Anaconda
If you have anaconda installed, you can just create a new environment for the project:
1. Open a terminal
2. Run `conda create -n ssd python=3.9`
3. Activate it using `conda activate ssd`

#### Virtual environment
In any case, you can still create a temporary environment for the project:
1. Open a terminal
2. Make sure you have Python 3.9 already installed by running `where python3.9` (if not, please install it)
3. Go to the project repository in your terminal using `cd path_to_project`
4. Run `path_to_your_python -m venv env`, where `path_to_your_python` is the one showed on step 2
4. Run `source env/bin/activate`

#### MacOS
In case you run on MacOS and have an Apple-M ship, you need to install torch without NNPACK (otherwise you would not be able to run the code). For that, follow these steps:
1. Open a terminal
2. Run `git clone --recursive https://github.com/pytorch/pytorch`
3. Run `cd pytorch`
4. Run `USE_NNPACK=0 python setup.py install`
5. Verify the installation: open a Python script and write `import torch; print(torch.__version__)`
6. Run `cd ..`
7. Run `rm -rf pytorch`

Note: you have now installed pytorch without NNPACK. You now need to comment out the `torch==2.2.2` line from the `requirements.txt` file in the root folder of the project. You can now proceed to the next step.

### Installing dependencies
As the title suggests, it's all good. You now have your Python environment ready specifically for the project. What is left to do is to installed the necessary packages. For that, you still need to run the following command in your terminal (from the project repository): `pip install -r requirements.txt`. Now you're done!

### Connect Python to MATLAB
Once your Python is settled up, you still need to link it to MATLAB. Follow these steps to do so:
1. Open MATLAB
2. Run the following command: `pyenv(Version="path_to_your_python3.9_environment")`; the path would either be the Anaconda one, or `path_to_project/env/bin/python`
3. Verify by running `pyenv` and `pyversion`; it should display the path you provided

### Run the project
Whenever running the code, users may have troubles running the code as it is. We experienced difficulties across our team as everyone did not have the same `PYTHONPATH`. To tackle this, please run the following command before running the code: `export PYTHONPATH=path_to_project` if you are on MacOS, or `set PYTHONPATH=path_to_project` if you are on Windows. Note that you need to write this command everytime you open a new terminal / close and open your IDE.

It should be all good now! Enjoy running the project :D

## Contact
Should you have any question regarding the code, feel free to contact us at:
- a.aurelien@student.maastrichtuniversity.nl.
- a.khalak@student.maastrichtuniversity.nl
- Jjvp.maes@student.maastrichtuniversity.nl
- b.vangool@student.maastrichtuniversity.nl
- r.langrock@student.maastrichtuniversity.nl
