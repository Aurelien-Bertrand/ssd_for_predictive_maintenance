addpath ./data_generation/
addpath ./data_generation/utils/

results = runtests(["TestGenerateImpulse", "TestTruncateSignal", "TestWindTurbine", "TestDataGenerator", "TestContinuousMonitoring"]);
