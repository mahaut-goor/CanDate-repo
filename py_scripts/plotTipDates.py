#!/usr/bin/env python3
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import r2_score
from sklearn.linear_model import LinearRegression

def plot_r2_curve(input_csv, output_png="r2_plot.png"):
    # Load CSV
    df = pd.read_csv(input_csv, header=0, index_col=0)
    required_cols = {"estimatedAge", "calC14_BP"}
    if not required_cols.issubset(df.columns):
        sys.exit(f"❌ CSV must contain columns: {required_cols}")

    # Extract values
    x = df["calC14_BP"].values.reshape(-1, 1)
    y = df["estimatedAge"].values

    # Fit regression model
    model = LinearRegression()
    model.fit(x, y)
    y_pred = model.predict(x)

    # Compute R²
    r2 = r2_score(y, y_pred)

    # Create plot
    plt.figure(figsize=(7, 6))
    plt.scatter(x, y, label="Samples", alpha=0.7)
    plt.plot(x, y_pred, color="red", label=f"Regression line (R² = {r2:.3f})")

    # Add sample name annotations with arrows
    for i in range(len(df)):
        plt.annotate(df.iloc[i].name, 
                    (x[i], y[i]),
                    xytext=(10, 10), 
                    textcoords='offset points',
                    fontsize=8,
                    arrowprops=dict(arrowstyle='->', color='black', lw=0.5))

    # Optional: 1:1 line for perfect fit
    plt.plot([x.min(), x.max()], [x.min(), x.max()], "k--", label="1:1 line")

    plt.xlabel("Real Age")
    plt.ylabel("Estimated Age")
    plt.title("Estimated vs. calBP Age (R² curve)")
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.5)
    plt.tight_layout()

    # Save plot
    plt.savefig(output_png, dpi=300)
    plt.close()

    print(f"✅ R² = {r2:.4f}")
    print(f"Plot saved to {output_png}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python plot_r2_curve.py <input.csv> [output.png]")
        sys.exit(1)

    input_csv = sys.argv[1]
    output_png = sys.argv[2] if len(sys.argv) > 2 else "r2_plot.png"
    plot_r2_curve(input_csv, output_png)
