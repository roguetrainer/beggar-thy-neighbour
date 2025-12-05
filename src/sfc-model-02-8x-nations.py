import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# --- 1. CONFIGURATION: The Starting State of the World (Approx 2024) ---
# Data sources: IMF WEO, World Bank, BEA
START_YEAR = 2024
YEARS_TO_SIMULATE = 30
INTEREST_RATE = 0.04  # Avg return on foreign assets/liabilities (r)

# Country Parameters: 
# 'g': Nominal GDP Growth Rate (Real + Inflation)
# 'target_tb': Structural Trade Balance Target (% of GDP). Positive = Surplus, Negative = Deficit.
# 'niip_gdp': Starting Net International Investment Position (% of GDP).
economies_config = [
    # The "Surplus" Bloc (Mercantilists)
    {'name': 'Germany',       'gdp': 5.0,  'g': 0.025, 'target_tb': 0.06,  'niip_gdp': 0.77, 'role': 'source'},
    {'name': 'Japan',         'gdp': 4.3,  'g': 0.020, 'target_tb': 0.04,  'niip_gdp': 0.88, 'role': 'source'},
    {'name': 'China',         'gdp': 19.4, 'g': 0.050, 'target_tb': 0.03,  'niip_gdp': 0.13, 'role': 'source'},
    {'name': 'Rest of Euro',  'gdp': 10.5, 'g': 0.030, 'target_tb': 0.01,  'niip_gdp': 0.10, 'role': 'source'},

    # The "Neutral" Bloc
    {'name': 'India',         'gdp': 4.1,  'g': 0.065, 'target_tb': -0.01, 'niip_gdp': -0.13, 'role': 'neutral'},
    {'name': 'Rest of World', 'gdp': 35.0, 'g': 0.035, 'target_tb': 0.00,  'niip_gdp': -0.10, 'role': 'neutral'},

    # The "Deficit" Bloc (Sinks)
    {'name': 'United Kingdom','gdp': 4.0,  'g': 0.030, 'target_tb': -0.03, 'niip_gdp': -0.30, 'role': 'sink'},
    # USA is the specific "Swing Producer" of global demand
    {'name': 'United States', 'gdp': 30.6, 'g': 0.035, 'target_tb': None,  'niip_gdp': -0.75, 'role': 'swing'},
]

class Economy:
    def __init__(self, config):
        self.name = config['name']
        self.gdp = config['gdp'] * 1e12 # Convert Trillions to actual number
        self.g = config['g']
        self.target_tb = config['target_tb']
        self.niip = self.gdp * config['niip_gdp']
        self.role = config['role']
        
        self.history = {
            'Year': [], 'GDP': [], 'NIIP': [], 'NIIP % GDP': [],
            'Trade Balance': [], 'Interest Payment': [], 'Current Account': []
        }

    def grow(self):
        self.gdp *= (1 + self.g)

    def calculate_interest(self):
        # r * Stock of Wealth
        return self.niip * INTEREST_RATE

    def update_wealth(self, current_account):
        self.niip += current_account
        
    def record(self, year, tb, interest, ca):
        self.history['Year'].append(year)
        self.history['GDP'].append(self.gdp)
        self.history['NIIP'].append(self.niip)
        self.history['NIIP % GDP'].append(self.niip / self.gdp)
        self.history['Trade Balance'].append(tb)
        self.history['Interest Payment'].append(interest)
        self.history['Current Account'].append(ca)

def run_simulation():
    # Initialize Economies
    countries = [Economy(c) for c in economies_config]
    
    print(f"Simulating Global Imbalances: {START_YEAR} to {START_YEAR + YEARS_TO_SIMULATE}")
    
    for year in range(START_YEAR, START_YEAR + YEARS_TO_SIMULATE):
        # 1. Calculate Global Trade Flows
        # Surplus/Neutral nations set their exports based on policy/structure
        global_surplus_usd = 0.0
        
        for c in countries:
            c.grow() # Economy grows first
            
            if c.role != 'swing':
                # Calculate their Trade Balance in Dollars
                tb_usd = c.gdp * c.target_tb
                global_surplus_usd += tb_usd
            
        # 2. The US (Swing) MUST absorb the remaining global surplus
        # Because the world is a closed system: Sum(Trade Balance) = 0
        us_tb_usd = -global_surplus_usd
        
        # 3. Calculate Interest & Update Stocks for EVERYONE
        for c in countries:
            # Determine Trade Balance
            if c.role == 'swing':
                tb = us_tb_usd
            else:
                tb = c.gdp * c.target_tb
            
            # Interest Flows (The "Snowball")
            interest = c.calculate_interest()
            
            # Current Account = Trade + Interest
            ca = tb + interest
            
            # Stock-Flow Update
            c.update_wealth(ca)
            
            # Record Data
            c.record(year, tb, interest, ca)

    return countries

def plot_results(countries):
    # Setup Dataframes
    df_results = {}
    for c in countries:
        df_results[c.name] = pd.DataFrame(c.history).set_index('Year')

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(18, 7))

    # CHART 1: The Divergence of Wealth (NIIP % GDP)
    for c in countries:
        # Highlight key players
        if c.name == 'United States':
            color, width, style = 'red', 4, '-'
        elif c.name == 'China':
            color, width, style = 'purple', 3, '-'
        elif c.name == 'Germany':
            color, width, style = 'blue', 3, '-'
        elif c.name == 'Japan':
            color, width, style = 'green', 3, '--'
        else:
            color, width, style = 'gray', 1, ':'
            
        ax1.plot(df_results[c.name].index, df_results[c.name]['NIIP % GDP'] * 100, 
                 label=c.name, color=color, linewidth=width, linestyle=style)

    ax1.axhline(0, color='black', linewidth=1)
    ax1.set_title("1. The Stock Trap: Net International Wealth (% of GDP)", fontsize=14, fontweight='bold')
    ax1.set_ylabel("Net Position (% GDP)")
    ax1.legend(loc='upper left', bbox_to_anchor=(1, 1))
    ax1.grid(True, alpha=0.3)

    # CHART 2: The US Detail (Trade vs Interest)
    us_df = df_results['United States']
    # Convert to Trillions for readability
    ax2.plot(us_df.index, us_df['Trade Balance'] / 1e12, label='Trade Balance (Goods/Services)', color='orange', linestyle='--')
    ax2.plot(us_df.index, us_df['Interest Payment'] / 1e12, label='Net Interest Payments', color='red', linewidth=3)
    ax2.fill_between(us_df.index, us_df['Trade Balance']/1e12, us_df['Interest Payment']/1e12, color='red', alpha=0.1)
    
    ax2.set_title("2. The US 'Doom Loop': When Interest Exceeds Trade", fontsize=14, fontweight='bold')
    ax2.set_ylabel("Trillions USD ($)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('output/global_sfc_simulation.png')
    plt.show()

if __name__ == "__main__":
    countries = run_simulation()
    plot_results(countries)