# beggar-thy-neighbour

**Visualizing the Pettis-Klein thesis: How domestic class wars drive global trade wars.**

This repository contains Python code and notebooks to reproduce the key economic arguments found in *Trade Wars Are Class Wars* by Michael Pettis and Matthew Klein. It fetches live data from the World Bank API to visualize the relationship between domestic income inequality (suppressed consumption) and global trade imbalances.

---
![TWCW](./img/Beggar-thy-neighbour.png)
---

The project name references the economic concept of [**Beggar-thy-neighbour**](https://en.wikipedia.org/wiki/Beggar_thy_neighbour), famously analyzed by Joan Robinson in her 1937 essay *"Beggar-My-Neighbour Remedies for Unemployment."* It describes a zero-sum policy where one country attempts to cure its own domestic problems (like unemployment or low growth) by running large trade surpluses, effectively "exporting" those problems to its trading partners.

## The Thesis

The project visualizes three core arguments from the book:
1.  **The Surplus Genesis:** How surplus nations (like China and Germany) suppress domestic consumption, forcing National Savings to exceed Investment.
2.  **The Deficit Mirror:** How deficit nations (like the US) absorb this excess capital, forcing Investment to exceed Savings.
3.  **The "Class War":** The suppression of household consumption as a share of GDP in surplus nations compared to the US.

## Directory Structure

```text
beggar-thy-neighbour/
├── src/             # Production scripts (Python)
├── notebooks/       # Interactive analysis (Jupyter)
├── docs/            # Methodology and Indicator references
└── output/          # Generated charts
```

## Setup & Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/yourusername/beggar-thy-neighbour.git](https://github.com/yourusername/beggar-thy-neighbour.git)
    cd beggar-thy-neighbour
    ```

2.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

## Usage

### Option 1: Run the Script
To generate the charts and save them to the `output/` folder:
```bash
python src/reproduce_charts.py
```

### Option 2: Interactive Notebook
To explore the data step-by-step:
```bash
jupyter notebook notebooks/trade_wars_viz.ipynb
```

## Data Source
All data is fetched programmatically from the **World Bank Open Data** API using the `pandas-datareader` library. No manual data download is required.

## License
MIT
