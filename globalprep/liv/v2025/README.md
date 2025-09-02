# Status of Livelihoods and Economies Update



### v2025 updates

- Renamed fishing to fis instead of cf. 
- Changed file structure organization such that livelihood and economies are two separate folders, as opposed nested inside each other
- New data from the WTTC for tourism job quantity and revenue.

Layers processed in 2025:

| Sector                                                   | Acronym |
|----------------------------------------------------------|---------|
| Fishing                                                  | fis     |
| Mariculture                                              | mar     |
| Tourism                                                  | tour    |


### v2024 updates

This year we decided to revamp both the LIV and ECO subgoals within LE for as many sectors as we could. The main sectors we decided to tackle were tourism (tour), mariculture (mar), and commercial fishing (cf), due to higher prevalence of data.

In 2024 we cleaned and prepped the best available data for most sectors and components included in this goal. The ECO subgoal was pursued, but LIV was tabled due to a lack of data in the fishing (cf) and tourism (tour) sectors. When newly updated data wasn't available, we re-downloaded and cleaned the previous data source. If needed to refer to, ohiprep_v2024 in v2023 contains all scripts and data produced during the 2023 fellows' deep dive. All of the v2024 cleaned files are now saved in the folder `~/ohiprep_v2024/globalprep/le/v2024/int`.


### v2023 updates

Detailed methods and explanations for v2023's work are available in the livelihoods_economies_dataprep.RMD saved in `~/ohiprep_v2023/globalprep/le/v2023`. Included below is a summary of what tasks were completed in the 2023 methods update.

For all datasets, except tourism revenue, the current format has one value for each country and year included in the dataset. Tourism uses a pre-cleaned version of the revenue data, so countries have already been converted to regions. We did not do any gapfilling to fill in countries missing from the cleaned data sets, so this will likely need to be done for most of the included data.

Acronyms for sectors used in the original output layers are used for simplicity of incorporating into the finalized OHI model. A new sector fish processing FP was added in this analysis, and will need to be incorporated into the model.


#### Acronyms for sectors used in the original output layers:

| Sector                                                   | Acronym |
|----------------------------------------------------------|---------|
| Fishing                                                  | cf      |
| Mariculture                                              | mar     |
| Tourism                                                  | tour    |
| Ports and Harbors                                        | ph      |
| Ship and Boat Building                                   | sb      |
| Aquarium Fishing                                         | aqf     |
| Transportation and Shipping                              | tran    |
| Marine Mammal Watching                                   | mmw     |
| Ocean Energy (formerly wave and tidal energy)            | wte     |
| Fish processing (not formerly included)                  | fp      |
| ? (unclear what this is, only in original revenue files) | og      |

#### Livelihoods (LIV)

We started with LIV, which included both the number and quality of jobs within a sector. The scripts used were:

-   `fis_jobs_prep.Rmd`
    -   Commercial fishing number of jobs (employment)
-   `fis_quality_prep.Rmd`
    -   Commercial fishing quality of jobs (wages)
-   `mar_jobs_prep.Rmd`
    -   Mariculture number of jobs (employment)
-   `tour_dataprep.Rmd`
    -   Tourism number and quality of jobs
-   `labor_force_dataprep.Rmd`
    -   Proportion of Tourism Jobs per Country/Region per Year, data from World Bank
    -   saves as labor_force.csv

## **Data sources**

### Livelihoods (LIV)

Fisheries quantity (jobs) prep: `fis_quantity_prep.Rmd`

- Labor Force data from World Bank (downloaded June 28. 2024)
  - <https://data.worldbank.org/indicator/SL.TLF.TOTL.IN>
- OECD (Employment in fisheries, aquaculture and processing, 2009 - 2021) (downloaded July 2, 2024)
  - <https://data-explorer.oecd.org/>
- FAO Yearbook (downloaded July 2, 2024) -- for cf job gapfilling if needed
  - <https://openknowledge.fao.org/server/api/core/bitstreams/2be6c2fa-07b1-429d-91c5-80d3d1af46a6/content>

Fisheries quality (wage) prep: `fis_quality_prep.Rmd`

- ILOSTAT (downloaded August 26, 2025) -- for cf wage data
  - <https://rshiny.ilo.org/dataexplorer46/?lang=en&id=EAR_4MTH_SEX_ECO_CUR_NB_A>
  - select Rev 3.1.B: Fishing
- OECD and FAO joint collection data (1995 - 2023) from Fabiana Cerasa (OECD) and Orsolya Mikecz (FAO)
  - `/home/shares/ohi/git-annex/globalprep/_raw_data/OECD_FAO_joint_collection/d2024`
  - Data was provided by email for Marine fishing (among other sectors) and aggregated by geo area and year for all sexes.

Mariculture quantity (jobs) prep:`mar_jobs_prep.Rmd`

- Mariculture number of jobs (employment)
  - Partially obtained from [FAO Fisheries and Aquaculture Statistical Yearbook](https://openknowledge.fao.org/server/api/core/bitstreams/2be6c2fa-07b1-429d-91c5-80d3d1af46a6/content)
  - Also brought in OECD data from their online [OECD Data Explorer](https://data-explorer.oecd.org/vis?df%5Bds%5D=DisseminateFinalDMZ&df%5Bid%5D=DSD_SOE%40DF_SOE&df%5Bag%5D=OECD.ENV.EPI&dq=.A....&pd=1995%2C2024&to%5BTIME_PERIOD%5D=false&vw=tb)

Tourism quantity and quality (jobs & wages):`tour_dataprep.Rmd`

- World Travel and Tourism Committee tourism jobs data
  - A data inquiry was filed with the WTTC and they very kindly agreed to provide the data necessary for tourism jobs as well as tourism revenue (to be used in economies, tourism). This data covers the time range 2008-2023. For future assessments, I would recommend filling out the data enquiry form again. The point of contact for 2025 was Chok Tsering:
    - `Chok.Tsering@wttc.org`. 
- Jobs data from UN Tourism / UNWTO 
    -  Key Tourism Statistics <https://www.unwto.org/tourism-statistics/key-tourism-statistics>
- Quality/Wage data from ILOSTAT (downloaded August 24, 2025) -- for tour/cf wage data
    - <https://rshiny.ilo.org/dataexplorer46/?lang=en&id=EAR_4MTH_SEX_ECO_CUR_NB_A>

Total Labor force: `labor_force_dataprep.Rmd`

- Labor Force data from World Bank (downloaded August 28, 2025)
    - <https://data.worldbank.org/indicator/SL.TLF.TOTL.IN>

