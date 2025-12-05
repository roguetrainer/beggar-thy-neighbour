import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# --- MODEL PARAMETERS ---
years = 50
initial_gdp = 100.0

# Economic Assumptions
growth_rate = 0.025      # 2.5% annual GDP growth (g)
interest_rate = 0.04     # 4.0% average yield on assets/debt (r)
# Note: If r > g, debt stabilizes only with a trade surplus. If deficit persists, it explodes.

# Trade Policies (The "Beggar-Thy-Neighbour" Setup)
# Surplus Bloc runs a trade surplus of 3% of GDP
surplus_bloc_tb_target = 0.03 

class Economy:
    def __init__(self, name, role):
        self.name = name
        self.role = role # 'surplus' or 'deficit'
        self.gdp = initial_gdp
        self.niip = 0.0  # Net International Investment Position (Asset - Liability)
        self.history = []

    def step(self, year, global_trade_balance_dollars):
        # 1. Grow GDP
        self.gdp = self.gdp * (1 + growth_rate)
        
        # 2. Determine Trade Flows
        # If surplus country, we SET the imbalance. If deficit, we ABSORB it.
        if self.role == 'surplus':
            trade_balance = self.gdp * surplus_bloc_tb_target
        else:
            # The Deficit bloc must absorb the surplus bloc's exports (Closed World)
            trade_balance = -global_trade_balance_dollars
        
        # 3. Calculate Interest Flows (The "Snowball")
        # Income earned on positive NIIP or paid on negative NIIP
        net_income_payment = self.niip * interest_rate
        
        # 4. Current Account = Trade Balance + Net Income
        current_account = trade_balance + net_income_payment
        
        # 5. Update Stock Position (SFC Constraint)
        # Previous Wealth + Current Flow = New Wealth
        self.niip = self.niip + current_account
        
        # Record Data
        self.history.append({
            'Year': year,
            'GDP': self.gdp,
            'Trade Balance': trade_balance,
            'Net Income (Interest)': net_income_payment,
            'Current Account': current_account,
            'NIIP (Net Wealth)': self.niip,
            'NIIP % GDP': (self.niip / self.gdp) * 100
        })
        
        return trade_balance if self.role == 'surplus' else 0

# --- RUN SIMULATION ---
china_germany = Economy("Surplus Bloc (China/EU)", "surplus")
usa = Economy("Deficit Bloc (USA)", "deficit")

print(f"Simulating {years} years of 'Beggar-Thy-Neighbour' dynamics...")
print(f"Assumptions: r={interest_rate:.1%}, g={growth_rate:.1%}, Trade Surplus={surplus_bloc_tb_target:.1%}")

for t in range(years):
    # Step 1: Surplus bloc sets the export volume
    global_imbalance = china_germany.step(t, 0) 
    # Step 2: Deficit bloc absorbs it
    usa.step(t, global_imbalance)

# --- PROCESS DATA ---
df_surplus = pd.DataFrame(china_germany.history)
df_deficit = pd.DataFrame(usa.history)

# --- VISUALIZATION ---
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Chart 1: The Trap (Trade vs Interest)
# Shows how Interest payments eventually become larger than the trade deficit itself
ax1.plot(df_deficit['Year'], df_deficit['Trade Balance'], label='US Trade Deficit (Goods)', color='blue', linestyle='--')
ax1.plot(df_deficit['Year'], df_deficit['Net Income (Interest)'], label='US Interest Payments', color='red', linewidth=2)
ax1.fill_between(df_deficit['Year'], df_deficit['Trade Balance'], df_deficit['Net Income (Interest)'], color='red', alpha=0.1)
ax1.set_title("The Debt Trap: When Interest Overtakes Trade", fontsize=14, fontweight='bold')
ax1.set_ylabel("Billions ($)")
ax1.set_xlabel("Year")
ax1.legend()
ax1.grid(True, alpha=0.3)

# Chart 2: The Exponential Divergence (Stock Positions)
ax2.plot(df_surplus['Year'], df_surplus['NIIP % GDP'], label='Surplus Bloc Net Wealth (% GDP)', color='green')
ax2.plot(df_deficit['Year'], df_deficit['NIIP % GDP'], label='US Net Debt (% GDP)', color='red')
ax2.axhline(0, color='black', linewidth=1)
ax2.set_title("Result: Exponential Divergence of Wealth", fontsize=14, fontweight='bold')
ax2.set_ylabel("Net International Investment Position (% of GDP)")
ax2.set_xlabel("Year")
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.suptitle(f"SFC Model: The Unsustainability of Structural Imbalances (r > g)", fontsize=16)
plt.tight_layout()
plt.show()