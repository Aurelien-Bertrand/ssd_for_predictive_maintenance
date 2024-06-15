# Run configuration
In order to run the code, several steps need to be undertaken.

## Python environment
In this project, we use an API to create a connection from MATLAB to Python. However, MATLAB only allows the use of Python 3.9 or earlier version.

It is best to create a virtual environment for this project. There are 2 possibilities:
### Anaconda
If you have anaconda installed, you can just create a new environment for the project:
1. Open a terminal
2. Run `conda create -n ssd python=3.9`
3. Activate it using `conda activate ssd`

### Virtual environment
In any case, you can still create a temporary environment for the project:
1. Open a terminal
2. Make sure you have Python 3.9 already installed by running `where python3.9` (if not, please install it)
3. Go to the project repository in your terminal using `cd path_to_project`
4. Run `path_to_your_python -m venv env`, where `path_to_your_python` is the one showed on step 2
4. Run `source env/bin/activate`

### MacOS
In case you run on MacOS and have an Apple-M ship, you need to install torch without NNPACK (otherwise you would not be able to run the code). For that, follow these steps:
1. Open a terminal
2. Run `git clone --recursive https://github.com/pytorch/pytorch`
3. Run `cd pytorch`
4. Run `USE_NNPACK=0 python setup.py install`
5. Verify the installation: open a Python script and write `import torch; print(torch.__version__)`
6. Run `cd ..`
7. Run `rm -rf pytorch`

Note: you have now installed pytorch without NNPACK. You now need to comment out the `torch==2.2.2` line from the `requirements.txt` file in the root folder of the project. You can now proceed to the next step.

### You're all set
As the title suggests, it's all good. You now have your Python environment ready specifically for the project. What is left to do is to installed the necessary packages. For that, you still need to run the following command in your terminal (from the project repository): `pip install -r requirements.txt`. Now you're done!

## Connect Python to MATLAB
Once your Python is settled up, you still need to link it to MATLAB. Follow these steps to do so:
1. Open MATLAB
2. Run the following command: `pyenv(Version="path_to_your_python3.9_environment")`; the path would either be the Anaconda one, or `path_to_project/env/bin/python`
3. Verify by running `pyenv` and `pyversion`; it should display the path you provided

## Run the project
It should be all good now! Enjoy running the project :D
