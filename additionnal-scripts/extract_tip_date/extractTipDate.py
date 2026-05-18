import pandas as pd
import numpy as np
import arviz as az
import sys

def hpd_interval(data, level=0.96):
    """Compute the Highest Posterior Density (HPD) interval."""
    sorted_data = np.sort(data)
    n = len(sorted_data)
    interval_idx_inc = int(np.floor(level * n))
    n_intervals = n - interval_idx_inc
    intervals = sorted_data[interval_idx_inc:] - sorted_data[:n_intervals]
    min_idx = np.argmin(intervals)
    hpd_min = sorted_data[min_idx]
    hpd_max = sorted_data[min_idx + interval_idx_inc]
    return hpd_min, hpd_max

def parse_beast_log(log_file, output_csv, param_filter="height"):
    # Load the log file
    df = pd.read_csv(log_file, comment="#", sep="\t", engine="python")

    # Drop burn-in (first 10% by default)
    burnin = int(0.1 * len(df))
    df = df.iloc[burnin:]

    results = []

    for col in df.columns:
        if param_filter in col:
            values = df[col].values
            mean = np.mean(values)
            median = np.median(values)
            ess_val = az.ess(np.array(values))
            ess = float(ess_val) if np.isscalar(ess_val) else float(ess_val.values.item())
            hpd_low, hpd_high = hpd_interval(values, level=0.96)

            results.append({
                "Parameter": col,
                "Mean": mean,
                "Median": median,
                "ESS": ess,
                "HPD_96_low": hpd_low,
                "HPD_96_high": hpd_high
            })

    # Convert to DataFrame and save
    out_df = pd.DataFrame(results)
    out_df.to_csv(output_csv, index=False)
    print(f"Results saved to {output_csv}")
    return out_df


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python parse_beast_log.py <input.log> <output.csv>")
        sys.exit(1)

    log_file = sys.argv[1]
    output_csv = sys.argv[2]
    parse_beast_log(log_file, output_csv)
