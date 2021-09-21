import os
import sys



def get_sample_list(input_dir):
    """A function to get a list of input sample reads from
    the input dir (reads_dir)
    
    Parameters:
    -----------------------------
        : input_dir (str): the path to the input directory
        
    Returns:
    -----------------------------
        : samples (list): list of file base names
    """
    samples = []
    for f in os.listdir(input_dir):
        base = os.path.basename(f)
        basename = os.path.splitext(base)[0]
        samples.append(basename)
    return samples
    
    