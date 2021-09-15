from PIL import Image

from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
import csv

LABEL_NAMES = ['background', 'kart', 'pickup', 'nitro', 'bomb', 'projectile']


class SuperTuxDataset(Dataset):
    def __init__(self, dataset_path):
        """
        Your code here
        Hint: Use the python csv library to parse labels.csv

        WARNING: Do not perform data normalization here. 
        """
        self.dataset_path = dataset_path
        self.data_list = []
        with open(f'{dataset_path}/labels.csv', mode='r') as csv_file:
            csv_reader = csv.DictReader(csv_file)
            for line in csv_reader:
                self.data_list.append(line)

    def __len__(self):
        """
        Your code here
        """
        return len(self.data_list)

    def __getitem__(self, idx):
        """
        Your code here
        return a tuple: img, label
        """
        obj = self.data_list[idx]
        file_name = obj.get('file')
        label_name = obj.get('label')

        if label_name == LABEL_NAMES[0]:
            label = 0
        elif label_name == LABEL_NAMES[1]:
            label = 1
        elif label_name == LABEL_NAMES[2]:
            label = 2
        elif label_name == LABEL_NAMES[3]:
            label = 3
        elif label_name == LABEL_NAMES[4]:
            label = 4
        else:
            label = 5

        I = Image.open(f'{self.dataset_path}/{file_name}')
        image_to_tensor = transforms.ToTensor()
        image = image_to_tensor(I)

        return image, label


def load_data(dataset_path, num_workers=0, batch_size=128):
    dataset = SuperTuxDataset(dataset_path)
    return DataLoader(dataset, num_workers=num_workers, batch_size=batch_size, shuffle=True, drop_last=False)


def accuracy(outputs, labels):
    outputs_idx = outputs.max(1)[1].type_as(labels)
    return outputs_idx.eq(labels).float().mean()
