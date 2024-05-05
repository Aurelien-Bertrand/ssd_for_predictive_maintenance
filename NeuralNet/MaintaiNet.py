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

PRINTER = False
PATIENCE = 3

class MaintainNet(nn.Module):
    def __init__(self, name, num_classes):
        super(MaintainNet, self).__init__()
        self.name = name
        self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
        print(f"Using device: {self.device}")

        # Define convolutional layers
        self.conv_layers = nn.ModuleList([
            nn.Conv1d(in_channels=1, out_channels=16, kernel_size=64, padding='same', stride=1),
            nn.Conv1d(in_channels=16, out_channels=32, kernel_size=3, padding='same', stride=1),
            nn.Conv1d(in_channels=32, out_channels=64, kernel_size=3, padding='same', stride=1),
            nn.Conv1d(in_channels=64, out_channels=128, kernel_size=3, padding='same', stride=1),
            nn.Conv1d(in_channels=128, out_channels=64, kernel_size=3, padding='same', stride=1),
            nn.Conv1d(in_channels=64, out_channels=32, kernel_size=3, padding='same', stride=1),
            nn.Conv1d(in_channels=32, out_channels=16, kernel_size=3, padding='same', stride=1),
            nn.Conv1d(in_channels=16, out_channels=8, kernel_size=3, padding='same', stride=1)
        ])

        # Define batch normalization layers
        self.batch_norm_layers = nn.ModuleList([
            nn.BatchNorm1d(num_features=x.out_channels) for x in self.conv_layers
        ])

        # Define a linear layer for the number of classes
        self.classifier = nn.Linear(8 * 1000, num_classes)  # Assuming the length of each feature map is 1000

        # Loss function and optimizer
        self.criterion = nn.CrossEntropyLoss().to(self.device)
        self.optimizer = optim.Adam(self.parameters(), lr=1e-3)

    def forward(self, x):
        # Convolutional layers with ReLU and pooling
        for conv, bn in zip(self.conv_layers, self.batch_norm_layers):
            x = F.relu(bn(conv(x)))
            x = F.max_pool1d(x, kernel_size=2, stride=2)

        # Flatten the output for the linear layer
        x = x.view(x.size(0), -1)  # Flatten

        # Classifier
        x = self.classifier(x)

        return x

    
    # Separate images into train, validation, and test sets
    def load_data(self, data, batch_size=64):

        # Separate inputs from target outputs
        xs = data[:, 1, :]
        ys = data[:, 0, :]
        
        # Normalize data [-1,1]
        xs = self.normalize_data(xs)

        # Convert to tensors
        xs = torch.tensor(xs, dtype=torch.float32)
        ys = torch.tensor(ys, dtype=torch.float32)
        
        xs = xs.unsqueeze(1)
        ys = ys.unsqueeze(1)


        # Create tensor dataset
        dataset = TensorDataset(xs, ys)

        # Separate data
        train_size = int(0.8 * len(data))
        validation_size = len(data) - train_size
        self.train_dataset, self.validation_dataset = random_split(dataset, [train_size, validation_size])


        # # Create dataloders
        self.train_loader = DataLoader(dataset=self.train_dataset, batch_size=batch_size, shuffle=True)
        self.validation_loader = DataLoader(dataset=self.validation_dataset, batch_size=batch_size, shuffle=True)


    def normalize_data(self, xs):
        self.min_val = xs.min()
        self.max_val = xs.max()

        xs_normal = 2 * (xs - self.min_val) / (self.max_val - self.min_val) - 1

        return xs_normal

    def unnormalize_data(self, data):
        return ((data + 1) / 2) * (self.max_val - self.min_val) + self.min_val
    
    # Function to train the autoencoder
    def train(self, num_epochs):
        val_losses = []
        train_losses = []
        patience_count = 0
        best_loss = math.inf
        for epoch in range(num_epochs):
            self.train()
            training_loss = 0
            for inputs, targets in tqdm(self.train_loader, desc=f"Epoch {epoch+1}/{num_epochs} [Training]", leave=False):

                inputs = inputs.to(self.device)
                targets = targets.to(self.device)

                self.optimizer.zero_grad()

                outputs = self(inputs)

                loss = self.criterion(outputs, targets)
                loss.backward()
                self.optimizer.step()
                training_loss += loss.item()
            
            self.eval()
            

            validation_loss = 0
            with torch.no_grad():
                for inputs, targets in tqdm(self.validation_loader, desc=f"Epoch {epoch+1}/{num_epochs} [Validation]", leave=False):

                    inputs = inputs.to(self.device)
                    targets = targets.to(self.device)

                    outputs = self(inputs)

                    loss = self.criterion(outputs, targets)
                    validation_loss += loss.item()

                    # Early stopping
                    if validation_loss >= best_loss:
                        patience_count += 1
                        if patience_count == PATIENCE:
                            print('Early stopping enabled')
                            break
                    else:
                        best_loss == validation_loss
                        patience_count == 0

            training_loss /= len(self.train_loader)
            validation_loss /= len(self.validation_loader)
            train_losses.append(training_loss)
            val_losses.append(validation_loss)
            print(f'Epoch {epoch+1}, Train Loss: {training_loss}, Validation Loss: {validation_loss}')

        return val_losses,  train_losses
    

    
    #Test on the test data
    def test(self):
        self.eval()  # Set the model to evaluation mode
        test_loss = 0.0
        with torch.no_grad():
            for inputs, targets in self.validation_loader:

                inputs = inputs.to(self.device)
                targets = targets.to(self.device)


                outputs = self(inputs)

                loss = self.criterion(outputs, targets)
                test_loss += loss.item()
                
        average_test_loss = test_loss / len(self.test_loader)
        print(f'Average Test Loss: {average_test_loss}')

    # Visualize an original image and the result from the autoencoder
    def infer(self, i=0, inputs=None):
        self.eval()  # Set the model to evaluation mode

        with torch.no_grad():
            if inputs == None:
                inputs, targets = next(iter(self.validation_loader))

            inputs = inputs.to(self.device)
            
            # Run inputs through the network
            outputs = self(inputs)

            # Move back to CPU if necessary
            inputs = inputs.cpu()
            outputs = outputs.cpu()
            targets = targets.cpu()

             # Convert tensors to numpy arrays
            input_signal = inputs.squeeze().numpy()[i]
            output_component  = outputs.squeeze().numpy()[i]
            target_component = targets.squeeze().numpy()[i]

            return input_signal, output_component, target_component
