#!/bin/bash

# Define the root directory
ROOT_DIR="beggar-thy-neighbour"

echo "Creating project structure for '$ROOT_DIR'..."

# Create directories
mkdir -p "$ROOT_DIR/src"
mkdir -p "$ROOT_DIR/notebooks"
mkdir -p "$ROOT_DIR/docs"
mkdir -p "$ROOT_DIR/output"

# 1. Create README.md
cat << 'EOF' > "$ROOT_DIR/README.md"
# beggar-thy-neighbour

**Visualizing the Pettis-Klein thesis: How domestic class wars drive global trade wars.**

This repository contains Python code and notebooks to reproduce the key economic arguments found in *Trade Wars Are Class Wars* by Michael Pettis and Matthew Klein. It fetches live data from the World Bank API to visualize the relationship between domestic income inequality (suppressed consumption) and global trade imbalances.

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
EOF

# 2. Create requirements.txt
cat << 'EOF' > "$ROOT_DIR/requirements.txt"
pandas
pandas_datareader
matplotlib
seaborn
requests
jupyter
EOF

# 3. Create src/__init__.py
cat << 'EOF' > "$ROOT_DIR/src/__init__.py"
# beggar-thy-neighbour package initialization
EOF

# 4. Create src/reproduce_charts.py (FULL CONTENT)
cat << 'EOF' > "$ROOT_DIR/src/reproduce_charts.py"
import pandas_datareader.wb as wb
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

# --- CONFIGURATION ---
START_YEAR = 1995
END_YEAR = 2022
COUNTRIES = ['CHN', 'DEU', 'USA']
COUNTRY_NAMES = {'CHN': 'China', 'DEU': 'Germany', 'USA': 'United States'}

# World Bank Indicator Codes
INDICATORS = {
    'NY.GDS.TOTL.ZS': 'Gross Domestic Savings (% of GDP)',
    'NE.GDI.TOTL.ZS': 'Gross Capital Formation (% of GDP)', # Proxy for Investment
    'NE.CON.PRVT.ZS': 'Households Final Consumption Expenditure (% of GDP)',
    'BN.CAB.XOKA.GD.ZS': 'Current Account Balance (% of GDP)'
}

def fetch_data():
    print("Fetching data from World Bank API... (This may take a moment)")
    try:
        # Fetch data for all countries and indicators at once
        df = wb.download(indicator=INDICATORS, country=COUNTRIES, start=START_YEAR, end=END_YEAR)
        
        # Reset index to make 'country' and 'year' columns
        df = df.reset_index()
        
        # Convert year to numeric
        df['year'] = pd.to_numeric(df['year'])
        
        # Rename columns for easier access
        df = df.rename(columns=INDICATORS)
        
        # Sort by country and year
        df = df.sort_values(by=['country', 'year'])
        return df
    except Exception as e:
        print(f"Error fetching data: {e}")
        return None

def plot_pettis_charts(df):
    # Set the visual style
    sns.set_theme(style="whitegrid")
    
    # Create a figure with 3 subplots (The 3 Key Arguments)
    fig = plt.figure(figsize=(18, 12))
    gs = fig.add_gridspec(2, 2)
    
    # --- CHART 1: The "Scissors" (China & Germany) ---
    # Argument: Surplus countries suppress consumption, pushing Savings > Investment.
    # The gap between the lines IS the trade surplus.
    ax1 = fig.add_subplot(gs[0, 0])
    
    # Plot China
    china_data = df[df['country'] == COUNTRY_NAMES['CHN']]
    ax1.plot(china_data['year'], china_data['Gross Domestic Savings (% of GDP)'], 
             label='China Savings', color='#d62728', linewidth=2.5)
    ax1.plot(china_data['year'], china_data['Gross Capital Formation (% of GDP)'], 
             label='China Investment', color='#d62728', linestyle='--', linewidth=2.5, alpha=0.7)
    
    # Plot Germany
    germany_data = df[df['country'] == COUNTRY_NAMES['DEU']]
    ax1.plot(germany_data['year'], germany_data['Gross Domestic Savings (% of GDP)'], 
             label='Germany Savings', color='#1f77b4', linewidth=2.5)
    ax1.plot(germany_data['year'], germany_data['Gross Capital Formation (% of GDP)'], 
             label='Germany Investment', color='#1f77b4', linestyle='--', linewidth=2.5, alpha=0.7)

    # Styling Chart 1
    ax1.set_title("1. The Surplus Genesis: Savings vs. Investment\n(The 'Scissors' Gap = Trade Surplus)", fontweight='bold')
    ax1.set_ylabel("% of GDP")
    ax1.legend()
    ax1.set_xlim(START_YEAR, END_YEAR)
    
    # Annotate the "Gap" concept
    ax1.text(2008, 52, "Savings > Investment\n= Forced Surplus", color='#d62728', fontsize=9, ha='center')

    # --- CHART 2: The "Sink" (United States) ---
    # Argument: The US absorbs the excess savings, forcing Investment > Savings.
    # The gap here is the Deficit.
    ax2 = fig.add_subplot(gs[0, 1])
    
    usa_data = df[df['country'] == COUNTRY_NAMES['USA']]
    
    ax2.plot(usa_data['year'], usa_data['Gross Domestic Savings (% of GDP)'], 
             label='US Savings', color='#2ca02c', linewidth=3)
    ax2.plot(usa_data['year'], usa_data['Gross Capital Formation (% of GDP)'], 
             label='US Investment', color='#ff7f0e', linestyle='--', linewidth=3)
    
    # Fill the deficit gap
    ax2.fill_between(usa_data['year'], 
                     usa_data['Gross Domestic Savings (% of GDP)'], 
                     usa_data['Gross Capital Formation (% of GDP)'], 
                     color='#ff7f0e', alpha=0.2, label='Capital Inflow (Deficit)')

    # Styling Chart 2
    ax2.set_title("2. The Deficit Mirror: US Absorbs Excess Capital\n(Investment > Savings = Funded by Foreigners)", fontweight='bold')
    ax2.set_ylabel("% of GDP")
    ax2.legend(loc='lower left')
    ax2.set_xlim(START_YEAR, END_YEAR)

    # --- CHART 3: The "Class War" (Household Consumption) ---
    # Argument: Surplus nations repress workers (low consumption share). 
    # Deficit nations (US) must consume more to balance global demand.
    ax3 = fig.add_subplot(gs[1, :]) # Spans bottom row
    
    ax3.plot(usa_data['year'], usa_data['Households Final Consumption Expenditure (% of GDP)'], 
             label='USA (Deficit/Consumer of Last Resort)', color='#2ca02c', linewidth=3)
    ax3.plot(germany_data['year'], germany_data['Households Final Consumption Expenditure (% of GDP)'], 
             label='Germany (Surplus/Suppressed)', color='#1f77b4', linewidth=3)
    ax3.plot(china_data['year'], china_data['Households Final Consumption Expenditure (% of GDP)'], 
             label='China (Surplus/Suppressed)', color='#d62728', linewidth=3)
    
    # Add annotation for Pettis's key point on China
    ax3.annotate('China\'s Consumption Share\nLowest in History?', 
                 xy=(2010, 34), xytext=(2000, 40),
                 arrowprops=dict(facecolor='black', shrink=0.05))

    # Styling Chart 3
    ax3.set_title("3. The Class War: Household Consumption Share of GDP\n(Surplus nations repress household income/spending)", fontweight='bold')
    ax3.set_ylabel("Household Consumption (% of GDP)")
    ax3.legend()
    ax3.set_xlim(START_YEAR, END_YEAR)

    plt.tight_layout()
    
    # Save to output folder
    output_path = os.path.join('output', 'pettis_klein_charts.png')
    plt.savefig(output_path, dpi=300)
    print(f"Charts saved to '{output_path}'")

if __name__ == "__main__":
    df = fetch_data()
    if df is not None:
        plot_pettis_charts(df)
EOF

# 5. Create notebooks/trade_wars_viz.ipynb (FULL CONTENT)
cat << 'EOF' > "$ROOT_DIR/notebooks/trade_wars_viz.ipynb"
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Trade Wars Are Class Wars: Visualizing the Thesis\n",
    "\n",
    "This notebook reproduces the key charts from Michael Pettis and Matthew Klein's book *Trade Wars Are Class Wars*.\n",
    "\n",
    "It visualizes three core arguments:\n",
    "1.  **The Surplus Genesis:** How China and Germany suppressed domestic consumption, forcing Savings > Investment.\n",
    "2.  **The Deficit Mirror:** How the US absorbs excess capital, forcing Investment > Savings.\n",
    "3.  **The \"Class War\":** The suppression of household consumption as a share of GDP in surplus nations compared to the US.\n",
    "\n",
    "Data is fetched live from the World Bank API."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Install necessary libraries if not already installed\n",
    "!pip install pandas pandas_datareader matplotlib seaborn requests"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas_datareader.wb as wb\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "\n",
    "# Ensure charts display inline and with high resolution\n",
    "%matplotlib inline\n",
    "%config InlineBackend.figure_format = 'retina'\n",
    "\n",
    "# --- CONFIGURATION ---\n",
    "START_YEAR = 1995\n",
    "END_YEAR = 2022\n",
    "COUNTRIES = ['CHN', 'DEU', 'USA']\n",
    "COUNTRY_NAMES = {'CHN': 'China', 'DEU': 'Germany', 'USA': 'United States'}\n",
    "\n",
    "# World Bank Indicator Codes\n",
    "INDICATORS = {\n",
    "    'NY.GDS.TOTL.ZS': 'Gross Domestic Savings (% of GDP)',\n",
    "    'NE.GDI.TOTL.ZS': 'Gross Capital Formation (% of GDP)', # Proxy for Investment\n",
    "    'NE.CON.PRVT.ZS': 'Households Final Consumption Expenditure (% of GDP)',\n",
    "    'BN.CAB.XOKA.GD.ZS': 'Current Account Balance (% of GDP)'\n",
    "}"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "def fetch_data():\n",
    "    \"\"\"Fetches and cleans data from the World Bank API.\"\"\"\n",
    "    print(\"Fetching data from World Bank API... (This may take a moment)\")\n",
    "    try:\n",
    "        # Fetch data for all countries and indicators at once\n",
    "        df = wb.download(indicator=INDICATORS, country=COUNTRIES, start=START_YEAR, end=END_YEAR)\n",
    "        \n",
    "        # Reset index to make 'country' and 'year' columns\n",
    "        df = df.reset_index()\n",
    "        \n",
    "        # Convert year to numeric\n",
    "        df['year'] = pd.to_numeric(df['year'])\n",
    "        \n",
    "        # Rename columns for easier access\n",
    "        df = df.rename(columns=INDICATORS)\n",
    "        \n",
    "        # Sort by country and year\n",
    "        df = df.sort_values(by=['country', 'year'])\n",
    "        return df\n",
    "    except Exception as e:\n",
    "        print(f\"Error fetching data: {e}\")\n",
    "        return None"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Execute data fetch\n",
    "df = fetch_data()\n",
    "\n",
    "# Display the first few rows to verify structure\n",
    "if df is not None:\n",
    "    display(df.head())"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "def plot_pettis_charts(df):\n",
    "    # Set the visual style\n",
    "    sns.set_theme(style=\"whitegrid\")\n",
    "    \n",
    "    # Create a figure with 3 subplots (The 3 Key Arguments)\n",
    "    fig = plt.figure(figsize=(18, 12))\n",
    "    gs = fig.add_gridspec(2, 2)\n",
    "    \n",
    "    # --- CHART 1: The \"Scissors\" (China & Germany) ---\n",
    "    # Argument: Surplus countries suppress consumption, pushing Savings > Investment.\n",
    "    # The gap between the lines IS the trade surplus.\n",
    "    ax1 = fig.add_subplot(gs[0, 0])\n",
    "    \n",
    "    # Plot China\n",
    "    china_data = df[df['country'] == COUNTRY_NAMES['CHN']]\n",
    "    ax1.plot(china_data['year'], china_data['Gross Domestic Savings (% of GDP)'], \n",
    "             label='China Savings', color='#d62728', linewidth=2.5)\n",
    "    ax1.plot(china_data['year'], china_data['Gross Capital Formation (% of GDP)'], \n",
    "             label='China Investment', color='#d62728', linestyle='--', linewidth=2.5, alpha=0.7)\n",
    "    \n",
    "    # Plot Germany\n",
    "    germany_data = df[df['country'] == COUNTRY_NAMES['DEU']]\n",
    "    ax1.plot(germany_data['year'], germany_data['Gross Domestic Savings (% of GDP)'], \n",
    "             label='Germany Savings', color='#1f77b4', linewidth=2.5)\n",
    "    ax1.plot(germany_data['year'], germany_data['Gross Capital Formation (% of GDP)'], \n",
    "             label='Germany Investment', color='#1f77b4', linestyle='--', linewidth=2.5, alpha=0.7)\n",
    "\n",
    "    # Styling Chart 1\n",
    "    ax1.set_title(\"1. The Surplus Genesis: Savings vs. Investment\\n(The 'Scissors' Gap = Trade Surplus)\", fontweight='bold')\n",
    "    ax1.set_ylabel(\"% of GDP\")\n",
    "    ax1.legend()\n",
    "    ax1.set_xlim(START_YEAR, END_YEAR)\n",
    "    \n",
    "    # Annotate the \"Gap\" concept\n",
    "    ax1.text(2008, 52, \"Savings > Investment\\n= Forced Surplus\", color='#d62728', fontsize=9, ha='center')\n",
    "\n",
    "    # --- CHART 2: The \"Sink\" (United States) ---\n",
    "    # Argument: The US absorbs the excess savings, forcing Investment > Savings.\n",
    "    # The gap here is the Deficit.\n",
    "    ax2 = fig.add_subplot(gs[0, 1])\n",
    "    \n",
    "    usa_data = df[df['country'] == COUNTRY_NAMES['USA']]\n",
    "    \n",
    "    ax2.plot(usa_data['year'], usa_data['Gross Domestic Savings (% of GDP)'], \n",
    "             label='US Savings', color='#2ca02c', linewidth=3)\n",
    "    ax2.plot(usa_data['year'], usa_data['Gross Capital Formation (% of GDP)'], \n",
    "             label='US Investment', color='#ff7f0e', linestyle='--', linewidth=3)\n",
    "    \n",
    "    # Fill the deficit gap\n",
    "    ax2.fill_between(usa_data['year'], \n",
    "                     usa_data['Gross Domestic Savings (% of GDP)'], \n",
    "                     usa_data['Gross Capital Formation (% of GDP)'], \n",
    "                     color='#ff7f0e', alpha=0.2, label='Capital Inflow (Deficit)')\n",
    "\n",
    "    # Styling Chart 2\n",
    "    ax2.set_title(\"2. The Deficit Mirror: US Absorbs Excess Capital\\n(Investment > Savings = Funded by Foreigners)\", fontweight='bold')\n",
    "    ax2.set_ylabel(\"% of GDP\")\n",
    "    ax2.legend(loc='lower left')\n",
    "    ax2.set_xlim(START_YEAR, END_YEAR)\n",
    "\n",
    "    # --- CHART 3: The \"Class War\" (Household Consumption) ---\n",
    "    # Argument: Surplus nations repress workers (low consumption share). \n",
    "    # Deficit nations (US) must consume more to balance global demand.\n",
    "    ax3 = fig.add_subplot(gs[1, :]) # Spans bottom row\n",
    "    \n",
    "    ax3.plot(usa_data['year'], usa_data['Households Final Consumption Expenditure (% of GDP)'], \n",
    "             label='USA (Deficit/Consumer of Last Resort)', color='#2ca02c', linewidth=3)\n",
    "    ax3.plot(germany_data['year'], germany_data['Households Final Consumption Expenditure (% of GDP)'], \n",
    "             label='Germany (Surplus/Suppressed)', color='#1f77b4', linewidth=3)\n",
    "    ax3.plot(china_data['year'], china_data['Households Final Consumption Expenditure (% of GDP)'], \n",
    "             label='China (Surplus/Suppressed)', color='#d62728', linewidth=3)\n",
    "    \n",
    "    # Add annotation for Pettis's key point on China\n",
    "    ax3.annotate('China\\'s Consumption Share\\nLowest in History?', \n",
    "                 xy=(2010, 34), xytext=(2000, 40),\n",
    "                 arrowprops=dict(facecolor='black', shrink=0.05))\n",
    "\n",
    "    # Styling Chart 3\n",
    "    ax3.set_title(\"3. The Class War: Household Consumption Share of GDP\\n(Surplus nations repress household income/spending)\", fontweight='bold')\n",
    "    ax3.set_ylabel(\"Household Consumption (% of GDP)\")\n",
    "    ax3.legend()\n",
    "    ax3.set_xlim(START_YEAR, END_YEAR)\n",
    "\n",
    "    plt.tight_layout()\n",
    "    plt.show()\n",
    "\n",
    "if df is not None:\n",
    "    plot_pettis_charts(df)"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# 6. Create docs/methodology.md
cat << 'EOF' > "$ROOT_DIR/docs/methodology.md"
# Methodology: The Economics of Class Wars

This document explains the economic framework used in *Trade Wars Are Class Wars* (Klein & Pettis, 2020) and how this project visualizes it using World Bank data.

## 1. The Core Identity
The analysis relies on the fundamental national accounting identity:

$$ CA = S - I $$

Where:
* **CA** = Current Account Balance (Trade Surplus/Deficit)
* **S** = National Savings
* **I** = Domestic Investment

### The Implication
A trade surplus ($CA > 0$) is **mathematically identical** to an excess of savings over investment ($S > I$).
A trade deficit ($CA < 0$) is **mathematically identical** to an excess of investment over savings ($I > S$).

Pettis and Klein argue that these imbalances are not caused by "better manufacturing" or "lazy consumers," but by distortions in income distribution that force $S$ and $I$ apart.

## 2. The Surplus Genesis (China & Germany)
In surplus countries, domestic policies (e.g., wage suppression, weak social safety nets, or subsidies for manufacturing) transfer wealth from households (who consume) to elites/corporations (who save).

* **Visual Evidence:** In the charts, you will see the **Gross Domestic Savings** line rise significantly above the **Investment** line.
* **The "Class War":** This gap represents consumption that *did not happen* because workers were not paid a high enough share of what they produced. This excess production must be exported.

## 3. The Deficit Mirror (The United States)
The world is a closed system. One country's surplus must be another's deficit. The US, with its deep, open financial markets, acts as the "consumer of last resort."

* **Visual Evidence:** In the charts, you will see US **Investment** consistently floating *above* US **Savings**.
* **The Misconception:** This is often blamed on Americans "spending beyond their means."
* **The Reality:** Foreign capital (the excess savings from China/Germany) flows into the US, pushing up asset prices and the dollar, which suppresses US savings and manufacturing competitiveness, *forcing* the deficit required to absorb the foreign surplus.

## 4. Household Consumption Share
The most direct measure of the "Class War" is **Household Final Consumption Expenditure as a % of GDP**.

* **Low Share:** Indicates that households retain a small slice of the economic pie (common in surplus nations).
* **High Share:** Indicates households retain more purchasing power (common in deficit nations).

By plotting these lines for China, Germany, and the US, we can see the structural divergence that drives trade conflict.
EOF

# 7. Create docs/indicators_list.md
cat << 'EOF' > "$ROOT_DIR/docs/indicators_list.md"
# World Bank Indicators

This project uses the following indicators from the World Bank Open Data API.

## Core Metrics

| Indicator Code | Name | Description | Pettis/Klein Relevance |
| :--- | :--- | :--- | :--- |
| **NY.GDS.TOTL.ZS** | Gross Domestic Savings (% of GDP) | The total savings of the public and private sectors. | High savings relative to investment indicates a structural surplus (The "Glut"). |
| **NE.GDI.TOTL.ZS** | Gross Capital Formation (% of GDP) | Domestic investment in fixed assets and inventory. | High investment is typical of developing economies, but must be matched by savings to avoid deficits. |
| **BN.CAB.XOKA.GD.ZS** | Current Account Balance (% of GDP) | The sum of net exports, net primary income, and net secondary income. | The "Scorecard" of trade wars. Matches the gap between Savings and Investment ($S - I$). |
| **NE.CON.PRVT.ZS** | Households Final Consumption Expenditure (% of GDP) | The market value of all goods and services purchased by households. | A proxy for the "Class War." Low consumption share implies income is being transferred from workers to elites/corporations. |
| **NV.IND.MANF.ZS** | Manufacturing, value added (% of GDP) | The net output of the manufacturing sector. | Used to visualize the "Manufacturing vs Deficit" correlation. |

## Region Codes
The project queries these specific ISO-3 country codes:
* `CHN`: China
* `DEU`: Germany
* `USA`: United States
* `CAN`: Canada (Optional comparison)
EOF

# 8. Create .gitignore
cat << 'EOF' > "$ROOT_DIR/.gitignore"
__pycache__/
*.pyc
.ipynb_checkpoints/
.env
venv/
output/*.csv
output/*.png
EOF

echo "Project structure and files created successfully in '$ROOT_DIR'."