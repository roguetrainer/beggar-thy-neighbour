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
