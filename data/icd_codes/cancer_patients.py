import argparse
from tqdm import tqdm
import pandas as pd
import numpy as np

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--original_file",
                        default="data\dx_eICU\icd_10_only.csv",
                        help="Insert your original file with ICD 10 codes")

    parser.add_argument("--result_file",
                        default="data\dx_eICU\sepsis_cancer_only.csv",
                        help="Insert your target path for the cancer ICD 10 codes only file")

    parser.add_argument("--dataset",
                    default="eICU",
                    help="Insert the dataset to work with")

    return parser.parse_args()

if __name__ == '__main__':

    args = parse_args()

    # Read the file to process with cancer patients
    df = pd.read_csv(args.original_file, header=0)

    # Narrow down to cancer ICD codes
    df = df[df.icd_10.str.contains("C")]

    # Get the mapping ICD codes - cancer type
    cancer_map = pd.read_csv("data\icd_codes\cancer_types.csv")

    # Go over each ICD code for cancer type, make true if our code matches
    for index, row in tqdm(cancer_map.iterrows(), total=len(cancer_map)):

        df[row.cancer_type] = df.icd_10.apply(lambda x: 1 if row.icd_10 in x else np.nan)

    # Get unique cancer types names
    unique_cancer_types = cancer_map.cancer_type.unique()

    # Encode as other if no cancer types has been detected, within our list
    df['other'] = ~df[unique_cancer_types].any(axis=1)
    df.other = df.other.apply(lambda x: np.nan if x == 0 else 1)

    print(f"Before groupping by patient, N = {len(df)}")

    # Group by patient
    if args.dataset == "MIMIC":
        df = df.groupby("subject_id").sum()

    elif args.dataset == "eICU":
        df = df.groupby("patientunitstayid").sum()

    # Convert these sums into 0 or 1 (anything >= 1)
    for index, row in cancer_map.iterrows():

        df[row.cancer_type] = df[row.cancer_type].apply(lambda x: 1 if x >= 1 else np.nan)
    
    # And same for 'other'
    df.other = df.other.apply(lambda x: 1 if x >= 1 else np.nan)
    
    print(f"After groupping by patient, N = {len(df)}")

    df.to_csv(args.result_file)