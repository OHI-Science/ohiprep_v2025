# Mapping status and conservation of global at-risk marine biodiversity

NOTE: This is code taken from https://github.com/oharac/spp_risk_dists

Written by: Casey C. O'Hara
Updated by: Carmen Hoyt (2025)

Here is an overview of the organization of files and data:

### Data

Most of the data used in this comes from the IUCN API, which is called on in the scripts. The API may change from year to year, so it is important to stay up to date on the documentation (see [rredlist](https://cran.r-project.org/web/packages/rredlist/rredlist.pdf)).  **However, you will need to download the new species range maps from these datasources for step 5:** 

* __Reference__: 
    * IUCN 2024. The IUCN Red List of Threatened Species. Version 2025-1. <http://www.iucnredlist.org>.
        * Shapefiles available from: https://www.iucnredlist.org/resources/spatial-data-download
        * __Downloaded__: July 15, 2025
        * Mazu locaton: *: /home/shares/ohi/git-annex/globalprep/_raw_data/iucn_spp
 
    *BirdLife International and Handbook of the Birds of the World (2024) Bird species distribution maps of the world. Version 2024.2. Available at http://datazone.birdlife.org/species/requestdis.
        * Zipped shapefile available from BirdLife International.  
        * __Downloaded__: July 2, 2025
* __Description__:  Shapefiles containing polygons of assessed species ranges; each shapefile represents all assessed species within a comprehensively-assessed (i.e. >90% assessed) taxonomic group.
* __Native data resolution__: NA
* __Time range__: NA
* __Format__:  Shapefile
* Mazu locaton: *: /home/shares/ohi/git-annex/globalprep/_raw_data/birdlife_intl/

[MEOW Regions](https://www.worldwildlife.org/publications/marine-ecoregions-of-the-world-a-bioregionalization-of-coastal-and-shelf-areas)

### Code

#### **Run this first!** Setup directory: `spp/v20XX/_setup`

In this directory are a sequence of files used to generate the bits and pieces that are later assembled into the rasters of biodiversity risk.

.Rmd files are sequenced with a prefix number to indicate the order of operations. Briefly:

1. `1_query_iucn_species_data.Rmd`

Pull information from the IUCN Red List API to determine...

- Marine Species List
- Subpopulation Assessments
- Taxa Info
- Habitat Info
- Comprehensive Assessments

...for *global* and *regional* assessments. We are interested in current (latest) and historical assessments for each.

**Note:** Some of these queries take a long time, so the results are saved in the `iucn` folder to avoid having to re-run.

Also calculate global and regional population trends.

2. `2_set_up_spatial_data.Rmd`

Update geographic scope of IUCN regional assessments (for *MEOW* regions), if necessary.

Set up spatial layers in Gall-Peters, 100 km<sup>2</sup> cells. (necessary?)

Layers copied from previous year:

- Cell ID (cells are sequentially numbered for combining with tabular data)
- Ocean area

Marine protected area layers generated: (necessary?)

- Classification 
- Year of protection
- Proportion of protection

3. `3_assess_iucn_spatial_data.Rmd`

Convert species range maps to rasters. For maps provided directly by IUCN, aggregate into multispecies files based on family.  There is some cleaning done at this stage to fix problematic extents and attributes.

From the list of all available maps, generate a master list of all mapped, assessed species for inclusion in the study. Rasterize each species to a .csv that includes cell ID and presence.  A .csv format was used for file size and ease of reading and binding into dataframes.

4. `4_process_iucn_spatial_data.Rmd`

Calculate species ranges from rasters.

Aggregate individual species ranges into larger taxonomic groups, and summarize key variables (mean risk, variance of risk, number of species, etc) by group. Technically this is not necessary but makes it easier to quality check the process along the way, and supports mapping at the level of taxonomic group rather than the entire species list level.

Archived methods (update only if necessary):
- Exclusive Economic Zones (EEZ)
- Marine Ecoregions of the World (MEOW)
- Bathymetry

range-rarity

DELETE BELOW when confirmed.

1. Pull information from the IUCN Red List API to determine an overall species list, habitat information, and current risk (conservation status).
    * 1_set_up_iucn_habs_and_risk.Rmd
2. Pull information from API on risk from regional assessments; also recode the regions according to Marine Ecoregions (Spalding et al, 2007) for later spatialization.
    * 2_set_up_iucn_risk_regional.Rmd
    * 2a_set_up_regional_codes.Rmd
3. Pull historical assessment information from API for possible trend analysis.
  * 3_set_up_iucn_trends.Rmd
4. Set up spatial layers in Gall-Peters, 100 km<sup>2</sup> cells.  Layers include:
    * cell ID (cells are sequentially numbered for combining with tabular data)
    * ocean area
    * marine protected area (classification, year of protection, proportion of protection)
    * Exclusive Economic Zones (EEZ) and FAO fishing regions
    * Marine Ecoregions of the World
    * bathymetry
    * NOTE: these layers are all saved in the `spp_risk_dists/_spatial` directory.
      * 4a_set_up_ocean_area_and_mpa_pct.Rmd
      * 4b_set_up_eez_meow_rasts.Rmd; You can skip this one. 
5. Convert species range maps to rasters. 
    * For maps provided directly by IUCN, aggregate into multispecies files based on family.  There is some cleaning done at this stage to fix problematic extents and attributes.
    * From the list of all available maps, generate a master list of all mapped, assessed species for inclusion in the study.
    * Rasterize each species to a .csv that includes cell ID and presence.  A .csv format was used for file size and ease of reading and binding into dataframes.
      * 5b_generate_spp_map_list.Rmd
      * 5c_rasterize_spp_shps.Rmd
6. Aggregate individual species ranges into larger taxonomic groups, and summarize key variables (mean risk, variance of risk, number of species, etc) by group.  
    * Technically this is not necessary but makes it easier to quality check the process along the way, and supports mapping at the level of taxonomic group rather than the entire species list level.
    * This process is done twice: once for uniform weighting and once for range-rarity weighting.  Resulting files are saved separately.
      * 6a_aggregate_spp_ranges.Rmd
      * 6b_aggregate_rr_spp_ranges.Rmd

#### Then run this!  Root directory: `v20XX`

At this level there are several scripts, prefixed `1x_biodiversity_maps`, that collate the various taxonomic group level files (generated in `setup` part 6) and summarize to the global level. These need to be run before spp_data_prep.Rmd!
  * 1a_biodiversity_maps_comp_assessed.Rmd
  * 1c_biodiversity_maps_all_spp.Rmd
  * spp_data_prep.Rmd

* Note each creates a specific aggregation - comprehensively assessed species vs all available species; uniform vs range-rarity weighting.
* The rasters generated in these scripts are saved in the `_output` folder.


### Data and output files

The `spp_risk_dists/_data` folder contains tabular data about IUCN species used throughout the processing of this analysis.  These files are generated by scripts in the setup directory.

The `spp_risk_dists/_spatial` folder contains general spatial data generated and/or used in the `setup` scripts.  These include:

* rasters for cell ID, EEZ ID, marine ecoregion ID, ocean area, and bathymetry masks.   
* tabular data of region names and lookups for IUCN regional assessment to marine ecoregion.
* tabular data of marine protected area level/year/coverage to cell ID.
* shapefiles used for map plotting from Natural Earth.

The `spp_risk_dists/_output` folder contains the rasters of biodiversity risk, species richness, variance of risk, etc generated from the scripts in the base directory.


Future iterations may include:

* Range-rarity-weighted mean and variance of risk
* Range rarity-weighted species richness

