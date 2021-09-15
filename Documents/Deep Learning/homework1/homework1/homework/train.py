import torch

from .models import ClassificationLoss, model_factory, save_model
from .utils import accuracy, load_data
import torch.utils.tensorboard as tb
import numpy as np

device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')
print('device = ', device)

def train(args):
    # setup logger
    log_dir = "logs/"
    train_logger = tb.SummaryWriter(log_dir + '/model/train', flush_secs=1)
    valid_logger = tb.SummaryWriter(log_dir + '/model/valid', flush_secs=1)

    # initialize some variables
    n_epochs = 100
    batch_size = 128

    # load the dataset
    train_dataset = load_data('data/train', batch_size=batch_size)
    valid_dataset = load_data('data/valid', batch_size=batch_size)

    # create network
    model = model_factory[args.model]()

    # create optimizer
    optimizer = torch.optim.SGD(model.parameters(), lr=0.01, momentum=0.9, weight_decay=1e-4)

    # create loss function
    loss = ClassificationLoss()

    # start training
    global_step = 0
    for epoch in range(n_epochs):

        for local_batch, local_labels in train_dataset:

            # compute output
            o = model.forward(local_batch)

            # compute the loss
            l = ClassificationLoss().forward(o, local_labels)

            # log loss
            train_logger.add_scalar('Train Loss', l, global_step=global_step)

            # compute the accuracy
            a = accuracy(o, local_labels)

            # log accuracy
            train_logger.add_scalar('Train Accuracy', a, global_step=global_step)

            # compute the gradient
            optimizer.zero_grad()

            # step
            l.backward()
            optimizer.step()

        # Evaluate on validation set
        for local_batch, local_labels in valid_dataset:
            valid_pred = model.forward(local_batch)

            acc = accuracy(valid_pred, local_labels)
            valid_logger.add_scalar('Valid Accuracy', acc, global_step=global_step)

            # iterate global_step
        global_step += 1

    save_model(model)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser()

    parser.add_argument('-m', '--model', choices=['linear', 'mlp'], default='linear')
    # Put custom arguments here

    args = parser.parse_args()
    train(args)
