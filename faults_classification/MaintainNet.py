import torch
from torch.utils.data import DataLoader, random_split
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import TensorDataset, DataLoader
import math
from tqdm import tqdm

from faults_classification._map_class_index_to_name import map_class_index_to_name

PRINTER = False
PATIENCE = 3

class MaintainNet(nn.Module):
    def __init__(self, name, num_classes):
        super(MaintainNet, self).__init__()
        self.name = name
        self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
        
        # Define convolutional layers
        self.conv_layers = nn.ModuleList([
            nn.Conv1d(in_channels=1, out_channels=16, kernel_size=64, padding=32),  # Adjusted padding
            nn.Conv1d(in_channels=16, out_channels=32, kernel_size=3, padding=1),   # Adjusted padding
            nn.Conv1d(in_channels=32, out_channels=64, kernel_size=3, padding=1),   # Adjusted padding
            nn.Conv1d(in_channels=64, out_channels=64, kernel_size=3, padding=1),   # Adjusted padding
            nn.Conv1d(in_channels=64, out_channels=32, kernel_size=3, padding=1),   # Adjusted padding
            nn.Conv1d(in_channels=32, out_channels=16, kernel_size=3, padding=1),   # Adjusted padding
            nn.Conv1d(in_channels=16, out_channels=1, kernel_size=3, padding=1),    # Adjusted padding
        ])
        
        # Define batch normalization layers
        self.batch_norm_layers = nn.ModuleList([
            nn.BatchNorm1d(num_features=x.out_channels) for x in self.conv_layers
        ])

        # Calculate size for the linear layer to match the output size of the last convolutional layer
        self.linear_input_size = 7

        # Define the linear layer
        self.classifier = nn.Linear(self.linear_input_size, num_classes)

        # Loss function and optimizer
        self.criterion = nn.CrossEntropyLoss()
        self.optimizer = optim.Adam(self.parameters(), lr=1e-3)

    def forward(self, x):
        # Convolutional layers with ReLU and pooling
        for i, (conv, bn) in enumerate(zip(self.conv_layers, self.batch_norm_layers)):
            x = F.relu(bn(conv(x)))
            x = F.max_pool1d(x, kernel_size=2, stride=2)  # Adjusted max pooling stride

        # Classifier
        x = self.classifier(x)

        return x

    def load_data(self, data, batch_size=64):
        N = data.shape[1] - 1

        xs = data.iloc[:, :N-1].to_numpy()
        ys = data.iloc[:, N].to_numpy()
        
        # Normalize data [-1,1]
        xs = self.normalize_data(xs)

        # Convert to tensors
        xs = torch.tensor(xs, dtype=torch.float32)
        ys = torch.tensor(ys, dtype=torch.float32)
        
        xs = xs.unsqueeze(1)

        # Create tensor dataset
        dataset = TensorDataset(xs, ys)

        # Separate data
        train_size = int(0.8 * len(data))
        validation_size = len(data) - train_size
        self.train_dataset, self.validation_dataset = random_split(dataset, [train_size, validation_size])

        # Create dataloaders
        self.train_loader = DataLoader(dataset=self.train_dataset, batch_size=batch_size, shuffle=True)
        self.validation_loader = DataLoader(dataset=self.validation_dataset, batch_size=batch_size, shuffle=True)
    
    def load_test_data(self, data, batch_size=64):
        N = data.shape[1] - 1

        xs = data.iloc[:, :N-1].to_numpy()
        ys = data.iloc[:, N].to_numpy()
        
        # Normalize data [-1,1]
        xs = self.normalize_data(xs)

        # Convert to tensors
        xs = torch.tensor(xs, dtype=torch.float32)
        ys = torch.tensor(ys, dtype=torch.float32)
        
        xs = xs.unsqueeze(1)

        # Create tensor dataset
        dataset = TensorDataset(xs, ys)

        # Create dataloaders
        self.test_loader = DataLoader(dataset=dataset, batch_size=batch_size, shuffle=True)
        
    def normalize_data(self, xs):
        self.min_val = xs.min()
        self.max_val = xs.max()

        xs_normal = 2 * (xs - self.min_val) / (self.max_val - self.min_val) - 1

        return xs_normal

    def unnormalize_data(self, data):
        return ((data + 1) / 2) * (self.max_val - self.min_val) + self.min_val
    
    def trainer(self, num_epochs):
        val_losses = []
        train_losses = []
        patience_count = 0
        best_loss = math.inf
        for epoch in range(num_epochs):
            self.train()
            training_loss = 0
            for inputs, targets in tqdm(self.train_loader, desc=f"Epoch {epoch+1}/{num_epochs} [Training]", leave=False):

                inputs = inputs.to(self.device)
                targets = targets.to(self.device).long()
                
                self.optimizer.zero_grad()

                outputs = self(inputs)
                outputs = outputs.squeeze(dim=1)

                loss = self.criterion(outputs, targets)
                loss.backward()
                self.optimizer.step()
                training_loss += loss.item()
            
            self.eval()

            validation_loss = 0
            with torch.no_grad():
                for inputs, targets in tqdm(self.validation_loader, desc=f"Epoch {epoch+1}/{num_epochs} [Validation]", leave=False):

                    inputs = inputs.to(self.device)
                    targets = targets.to(self.device).long()

                    outputs = self(inputs)
                    outputs = outputs.squeeze(dim=1)

                    loss = self.criterion(outputs, targets)
                    validation_loss += loss.item()

                    if validation_loss >= best_loss:
                        patience_count += 1
                        if patience_count == PATIENCE:
                            print('Early stopping enabled')
                            break
                    else:
                        best_loss = validation_loss
                        patience_count = 0

            training_loss /= len(self.train_loader)
            validation_loss /= len(self.validation_loader)
            train_losses.append(training_loss)
            val_losses.append(validation_loss)
            print(f'Epoch {epoch+1}, Train Loss: {training_loss}, Validation Loss: {validation_loss}')

        return val_losses,  train_losses
    
    def test(self):
        self.eval()
        test_loss = 0
        correct = 0
        total = 0
        with torch.no_grad():
            for inputs, targets in tqdm(self.test_loader, desc="Testing", leave=False):
                inputs = inputs.to(self.device)
                targets = targets.to(self.device).long()

                outputs = self(inputs)
                outputs = outputs.squeeze(dim=1)

                loss = self.criterion(outputs, targets)
                test_loss += loss.item()

                _, predicted = torch.max(outputs, 1)
                total += targets.size(0)
                correct += (predicted == targets).sum().item()

        test_loss /= len(self.test_loader)
        accuracy = 100 * correct / total
        print(f'Test Loss: {test_loss}, Accuracy: {accuracy}%')

    def predict(self, input):
        self.eval()  # Set the model to evaluation mode

        with torch.no_grad():
            input = torch.tensor(input, dtype=torch.float32)

            input = input.to(self.device)
            input = self.normalize_data(input)
            input = input.unsqueeze(0)
            input = input.unsqueeze(0)
            
            # Run inputs through the network
            output = self(input)

            # Move back to CPU if necessary
            output = output.cpu()

             # Convert tensors to numpy arrays
            output  = output.squeeze().numpy()

            output = np.argmax(output)
            
            return map_class_index_to_name(int(output))
