t0 = Sys.time()

cl <- makeCluster(2)
registerDoParallel(cl)
foreach(p=c("n", "s"), .packages = c("raster", "fasterize", "sf", "sp", "fields", "here", "tictoc", "dplyr", "ggplot2")) %dopar% { 
  
  #p="s" # testing
  #p = "n"
  
  ######################################################################################################################
  ## Create an empty raster stack with appropriate dimensions and CRS
  ######################################################################################################################
  
  ## extents from NSIDC (http://nsidc.org/data/polar_stereo/ps_grids.html)
  
  if (p == "n"){
    xMin = -3850000; yMin = -5350000; nr = 448; nc = 304; prj = prj.n; fp = fp.n; cor = "N" #added
  } else if (p == "s"){
    xMin = -3950000; yMin = -3950000; nr = 332; nc = 316; prj = prj.s; fp = fp.s; cor = "S" #added
  }

  xMax = xMin + (pixel*nc); yMax = yMin + (pixel*nr)

  r <- raster(nrow = nr, ncol = nc, xmn = xMin, xmx = xMax, ymn = yMin, ymx = yMax)
  projection(r) <- prj
  s <- stack(r)
  
  ######################################################################################################################
  ## Collect the data for each month/year from the website and add to raster stack
  ######################################################################################################################
  
  for (yr in years){
    for (mo in months){ 
      
      #yr=1979; mo=1 # testing
      #yr = 2018; mo = 1
      
      ## get proper ftp (file transfer protocol) site based on time of data collection    
      i.pym <- i.pym + 1 
      ym <- yr*100 + mo
      y.m <- sprintf("%d-%02d", yr, mo)
      p.y.m <- sprintf("%s%d%02d", p, yr, mo)
      
      
      if (ym < 198709){
        ss = "n07"
      } else if (ym >= 198709 & ym < 199201){
        ss = "f08"
      } else if (ym >= 199201 & ym < 199510){
        ss = "f11"
      } else if (ym >= 199510 & ym < 200801){
        ss = "f13"
      } else if (ym >= 200801){
        ss = "f17"
      }
      
      ## retrieving the data using ftp
      min.done <- as.numeric(difftime(Sys.time(), t0, units="mins"))
      min.togo <- (n.pym - i.pym) * min.done/i.pym
      print(sprintf("Retrieving %s (%d of %d). Minutes done=%0.1f, to go=%0.1f",
                    p.y.m,i.pym,n.pym,min.done,min.togo)) # time remaining for data download
      
      
      #locate the file
      u <- sprintf("%s/NSIDC0051_SEAICE_PS_%s25km_%d_v2.0.nc", fp, cor, ym)
      
      
      #save as a raster 
      r <- raster(u)
      
    
      ## raster values: 254=land, 253=coast, 251=north pole assumed ice not seen by satellite
      ## 0 to 250 / 250 = % ice concentration (see raster::calc documentation)
      
      #2023 update-the data read in already appears to be scaled from 0 to 1
      #scaling it back to run the rest of the function
      r <- r * 250
      
      ##################################################################################################################
      ## Creates pts shp file if does not exist (n_type_rgns_pts.shp or s_type_rgns_pts.shp)
      ##################################################################################################################
      
      ## The next function only runs if the pts.shp file does not exist (it should exist in the folder).
      ## First, this takes the ice data and coverts it to a tif file (n_type or s_type) that identifies
      ## the: coast, land, hole, water, shore (25 km offshore from coast) based on codes in each ice data file.
      ##
      ## Second, the OHI region shapefile is read in (the CRS has been transformed using ArcGIS).
      ## Originally, the following was performed with ArcGIS using a python script, but these functions are now done in R
      ## (most of this has been converted to R, except for step 1 below - which was performed in ArcGIS):
      ##
      ##    1. convert the OHI regions shp file to a raster with the appropriate extent and CRS
      ##    3. converts the raster to a points shp file
      ##    4. appends "type" information generated from the nsdic data (i.e., n_type or s_type data) to the OHI raster:
      ##        land  = 0
      ##        coast = 1
      ##        shore = 2
      ##        water = 3
      ##        hole  = 4 (north pole)
      ##    5. saves file as: n_type_rgns_pts.shp or s_type_rgns_pts.shp
      
      ##################################################################################################################
      
      
      pts.shp <- file.path(maps, sprintf("tmp/%s_type_rgns_pts.shp", p))
      
      ## if the pts.shp file exists in the assessment year git-annex NSIDC_SeaIce tmp folder, this code is not run      
      if (!file.exists(pts.shp)){
        
        ## These take the raster cells that are identified as something other than ice (i.e., land, water, etc.)
        ## and creates new raster layers with just those cells
        
        
        r_coast = r == 253
        r_land = r == 254
        r_hole = r == 251
        r_water = r <= 250
        
        
        r_coast_na <- calc(r_coast, fun = function(x) { x[x == 0] = NA; return(x) }) # replaces 0 values with NA in r_coast file
        r_coast_distance <- distance(r_coast_na) # calculates distance from coast (units are in meters)
        r_shore <- r_water == 1 & r_coast_distance < pixel*1.1 # selects one pixel offshore from coast: 25km offshore
        
        r_type <- r
        
        r_type[r_land == 1] = 0
        r_type[r_coast == 1] = 1
        r_type[r_water == 1] = 3
        r_type[r_shore == 1] = 2
        r_type[r_hole == 1] = 4
        
        writeRaster(r_type, 
                    file.path(dir_M, sprintf("git-annex/globalprep/_raw_data/NSIDC_SeaIce/%s/tmp/%s_type.tif", assess_year, p)),
                    overwrite=T) # r_type in memory, read r.typ from file for increased speed
        
        
        r.typ <- raster(file.path(dir_M, sprintf("git-annex/globalprep/_raw_data/NSIDC_SeaIce/%s/tmp/%s_type.tif", assess_year, p)))
        OHIregion <- read_sf(dsn = file.path(dir_M, "git-annex/globalprep/_raw_data/NSIDC_SeaIce/v2015/raw"), 
                             layer = sprintf("New_%s_rgn_fao", p)) # projected ohi regions, read as simple features object
        OHIregion <- OHIregion %>%
          dplyr::filter(!is.na(st_dimension(OHIregion))) %>%
          st_cast("MULTIPOLYGON") # clean up regions with no geometry
        
        ## convert OHIregion multipolygon sf to a raster, replace NAs with zeroes, convert to points sf, add some attributes
        ## with spatial = TRUE option, st_as_sf(rasterToPoints()) turns raster first into spatialPointsDataFrame then sf...
        OHIregion_raster <- fasterize(OHIregion, r.typ, field = "rgn_id")
        OHIregion_raster[is.na(OHIregion_raster)] <- 0
        OHIregion_points <- st_as_sf(rasterToPoints(OHIregion_raster, spatial = TRUE)) # is there a better approach??
        names(OHIregion_points)[1] <- "rgn_id"
        OHIregion_points <- dplyr::left_join(OHIregion_points, OHIregion %>% st_set_geometry(NULL), by = "rgn_id")
        
        ## add type_nsidc to the points (changed this from last year, to extract just using sf+dplyr not sp)
        ## setdiff() check showed no difference between the methods
        library(dplyr)
        OHIregion_points <- OHIregion_points %>% dplyr::mutate(type_nsidc = raster::extract(r.typ, OHIregion_points))
        st_write(OHIregion_points, dsn = file.path(maps, "tmp"), 
                 driver = "ESRI Shapefile", layer = sprintf("%s_type_rgns_pts",p), append = FALSE)
      }
      
      ##################################################################################################################
      ## Add each downloaded raster to the raster stack, extract data from each raster, and save to shp point file
      ##################################################################################################################
      
      ## If at the start of the data, this reads in the points shp file created above
      ## assumes that the range starts with january 1979 (yr==1979, mo==1)
      if (yr == 1979 & mo == 1){
        pts <- st_read(dsn = file.path(maps, "tmp"), layer = sprintf("%s_type_rgns_pts", p))
      }
      
      ## add raster data (r) to the stack (s) and name the layer: pole.year.month (e.g. s197901)
      s.names <- names(s)
      
      if (nlayers(s) == 0){ 
        s = stack(r)
        names(s) = p.y.m
      } else {
        s = stack(s, r)
        names(s) = c(s.names, p.y.m)   
      }
      
      ## extract data from the downloaded raster and append it to the type_rgns_pts shp file
      pts <- pts %>% dplyr::mutate(p.y.m = raster::extract(r, pts))
      names(pts)[names(pts) == "p.y.m"] <- p.y.m 
    }
  }
  
  ######################################################################################################################
  ## Save stack of rasters and pts of shore as rdata file
  ######################################################################################################################
  
  save_loc <- file.path(
    dir_M, sprintf("git-annex/globalprep/_raw_data/NSIDC_SeaIce/%s/%s_rasters_points.rdata", assess_year, p))
  save(s, pts, file=save_loc)
}
stopCluster(cl)