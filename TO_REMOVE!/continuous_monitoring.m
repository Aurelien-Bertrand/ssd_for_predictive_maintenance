addpath ../utils/
addpath ../data_generation/

model = get_maintain_network(2);

generator = RealisticGenerator(2560, 3, 0);
dataset = generator.generate_dataset(1, 0, 1);
x = dataset.signals(1,1:1000);

output = model.predict(x)
