import sys
import os
from pathlib import Path
import yaml
from datetime import datetime
import numpy as np
import pandas as pd
import aicsimageio
import aicsimageio.readers as ar


def get_config(config_path):
    """A function to load the config fromthe config path
    
    Parameters:
    -----------------------------
        : config_path (str): the input path to the config
        
    Returns:
    -----------------------------
        : config (dict): parameters from the config
    """
    with open(config_path, 'r') as stream:
        try:
            config = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc) 
    return config


def load_image(config):
    """A function to load the image from the file path. This is expected to return an image with
    the following dimensions:
    
        (1, time, channels, y_pixels, x_pixels)
        
    Parameters:
    -----------------------------
        : config (dict): parameters from the config
        
    Returns:
    -----------------------------
        : img (aicsimageio.readers.czi_reader.CziReade): img and metadata
    """
    img = ar.czi_reader.CziReader(config['img_path'])
    return img
    


def split_channels(img, config):
    """A function to return a dict with separate tensors for each channel.
    Tensors with be the image size for n timepoints. 
    
    NOTE: for now this assumes a constant structured image, per `load_image()`
    
    Parameters:
    -----------------------------
        : img (aicsimageio.readers.czi_reader.CziReade): img and metadata
        : config (dict): parameters from the config
        
    Returns:
    -----------------------------
        : channels (dict): keys are channel names (from config keys) and values are time-lapse tensors 
    """
    channels = {}
    
    for channel_name in config['channels']:
        channel_idx = config['channels'][channel_name] - 1
        channel_image = img.data[0, :, channel_idx, :, :]
        channels[channel_name] = channel_image
        
    return channels
        

def write_channels(channels, config):
    """A function to save numpy arrays for future computation. Each numpy array is 
    a time-lapse image tensor.
    
    Parameters:
    -----------------------------
        : channels (dict): keys are channel names (from config keys) and values are time-lapse tensors 
        : config (dict): parameters from the config
        
    Returns:
    -----------------------------
        : NA: storing funciton only, output depends on the statistics file
    """
    # build the subdir
    raw_channel_array_dir = f"{config['output']}raw_channel_arrays"
    Path(raw_channel_array_dir).mkdir(exist_ok=True)
    
    for channel, tensor in channels.items():
        image_path = f"{raw_channel_array_dir}/{channel}_raw.npy"
        np.save(image_path, tensor) 
        

def get_raw_image_statistics(channels, config):
    """A function to compute a number of mesaures from the raw image
    
    Parameters:
    -----------------------------
        : channels (dict): keys are channel names (from config keys) and values are time-lapse tensors 
        : config (dict): parameters from the config
        
    Returns:
    -----------------------------
        : raw_statistics (pd.DataFrame): a tabular summary of the raw images
    """
    
    new_rows = []
    
    for channel, tensor in channels.items():
        
        for t in range(tensor.shape[0]):
            img = tensor[t, :, :]
            
            row = {
                'channel' : channel,
                'time' : t,
                'image_size' : img.shape,
                'mean_intensity' : img.mean(),
                'std_intensity' : img.std(),
                'meidan_intensity' : np.median(img),
                'min_intensity':  img.min(),
                'max_intensity':  img.max(),
            }
            
            new_rows.append(row)
    
    raw_statistics = pd.DataFrame(new_rows)
    return raw_statistics

if __name__ == "__main__":
  
    # get parameters
    config = get_config(sys.argv[1])
    
    # load the image into standard format
    img = load_image(config)
    
    # split the the channels 
    channels = split_channels(img, config)
    
    # save the separate channels
    write_channels(channels, config)
    
    # get image stats
    # NOTE: this function is required so that snakemake has a file to write
    raw_statistics = get_raw_image_statistics(channels, config)
    raw_statistics.to_csv(sys.argv[2], index=False)

    
