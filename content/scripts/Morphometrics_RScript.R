#### SAVE AND LOAD WORKSPACE####

#### PACKAGES####
library(geomorph)
library(morphoBlocks)
library(Morpho)
library(vegan)
library(ggplot2)
library(MASS)
library(SlicerMorphR)
library(abind)
library(dplyr)
library(stringr)

#### LOAD DATA, CREATE ARRAYS (WHOLE DATAFRAME)####

# Define base directory
base_dir <- "Your_Directory_Here"

# Define curve metadata
curve_info <- list(
  curve1 = list(points = 21),
  curve2 = list(points = 21),
  curve3 = list(points = 16),
  curve4 = list(points = 16),
  curve5 = list(points = 21),
  curve6 = list(points = 16),
  curve7 = list(points = 16)
)
# Create lists to store data
curve_coords <- list()

# Load data dynamically
for (i in seq_along(curve_info)) {
  curve_name <- names(curve_info)[i]
  num_points <- curve_info[[curve_name]]$points
  curve_dir <- file.path(base_dir, paste0("resampled_", curve_name))
  
  # Read files
  setwd(curve_dir)
  files <- dir(pattern = 'json')
  
  # Create array
  curve_array <- array(dim = c(num_points, 3, length(files)))
  for (j in seq_along(files)) {
    curve_array[,,j] <- read.markups.json(files[j])
  }
  
  # Assign names
  dimnames(curve_array) <- list(paste0("LM", 1:num_points), c("X", "Y", "Z"), files)
  
  # Store full dataset
  curve_coords[[curve_name]] <- curve_array
  
}
# Combine data sets for each bone
CB1_curves <- abind(curve_coords$curve1, curve_coords$curve2, curve_coords$curve3, curve_coords$curve4[-1,,], along = 1)
CB2_curves <- abind(curve_coords$curve5, curve_coords$curve6, curve_coords$curve7[-1,,], along = 1)

#### DEFINE SLIDERS, RUN GPA#### 
sliders_CB1 = rbind (define.sliders(c(1:21)), define.sliders(c(22:42)), define.sliders(c(43:58)), define.sliders(c(58:73)))
sliders_CB2 = rbind (define.sliders(c(1:21)), define.sliders(c(22:37)), define.sliders(c(37:52)))

GPA_CB1 <- gpagen(CB1_curves, curves = sliders_CB1)
plot(GPA_CB1)
GPA_CB2 <- gpagen(CB2_curves, curves= sliders_CB2)
plot(GPA_CB2)

plotOutliers(GPA_CB1$coords)#,inspect.outliers = TRUE)

plotOutliers(GPA_CB2$coords)#,inspect.outliers = TRUE)

#### PCA ANALYSIS WHOLE DATAFRAME####
# Perform PCAs
pca_CB1<- gm.prcomp(GPA_CB1$coords)
pca_CB2 <- gm.prcomp(GPA_CB2$coords)

# Load Data & Create Geomorph Data Frames for X23
# Read in the data
df_X23_X24 <- read.csv("//resstore.unibe.ch/iee_evol/BenSulser/microCT_Stickleback/gdf_X23_X24_reordered.CSV", sep = ";", stringsAsFactors = TRUE)

gdf_CB1 <- geomorph.data.frame(GPA_CB1, Year=df_X23_X24$Year, ID=df_X23_X24$Specimen_ID, Sex=df_X23_X24$Sex, Lake=df_X23_X24$Lake, Ecology=df_X23_X24$ecology,Standard_length=df_X23_X24$body_size, Raker_lat_mean=df_X23_X24$raker_lat_mean,Raker_med_mean=df_X23_X24$raker_med_mean,Raker_spacing=df_X23_X24$mean_spacing, Raker_nr=df_X23_X24$R1_raker_nr)
gdf_CB2 <- geomorph.data.frame(GPA_CB2, Year=df_X23_X24$Year ,ID=df_X23_X24$Specimen_ID, Sex=df_X23_X24$Sex, Lake=df_X23_X24$Lake, Ecology=df_X23_X24$ecology,Standard_length=df_X23_X24$body_size, Raker_lat_mean=df_X23_X24$raker_lat_mean,Raker_med_mean=df_X23_X24$raker_med_mean,Raker_spacing=df_X23_X24$mean_spacing, Raker_nr=df_X23_X24$R1_raker_nr)

#### PCA PLOTS WHOLE DF, COLORED BY ECOLOGY####
par(mfrow = c(1, 1))

# Define colors
colors_ecology <- c("benthic"="darkorange", "limnetic"="dodgerblue3")

# Function to plot PCA
plot_pca <- function(pca_data, gdf, color_var, color_palette, title_prefix) {
  # Default PCA plot
  plot(pca_data, main = paste("PCA of", title_prefix), 
       col = color_palette[gdf[[color_var]]], pch = 16, cex = 1.5)
  legend("topright", legend = names(color_palette), col = color_palette, 
         pch = 16, title = color_var, cex = 0.8)
  
  # Loop for additional PC combinations
  for (x in 1:3) {
    for (y in (x+1):4) {
      plot(pca_data, main = paste("PCA of", title_prefix), 
           col = color_palette[gdf[[color_var]]], pch = 16, cex = 1.5, 
           axis1 = x, axis2 = y)
      legend("topright", legend = names(color_palette), col = color_palette, 
             pch = 16, title = color_var, cex = 0.8)
    }
  }
}
# CB1
PCA_CB1_eco <- plot(pca_CB1, main = "PCA of CB1", col = colors_ecology[gdf_CB1$Ecology], pch = 16, cex = 1.5, plot = FALSE)
PCA_CB1_1_3_eco <- plot(pca_CB1, main = "PCA of CB1", col = colors_ecology[gdf_CB1$Ecology], pch = 16, cex = 1.5, axis1 = 1, axis2 = 3, plot = FALSE)

# CB2
PCA_CB2_eco <- plot(pca_CB2, main = "PCA of CB2", col = colors_ecology[gdf_CB2$Ecology], pch = 16, cex = 1.5, plot = FALSE)
PCA_CB2_1_3_eco <- plot(pca_CB2, main = "PCA of CB2", col = colors_ecology[gdf_CB2$Ecology], pch = 16, cex = 1.5, axis1 = 1, axis2 = 3, plot = FALSE)

#function for plots with hulls
make_ggplot_ellipse <- function(object, x_label = "PC1", y_label = "PC2", plot_title = "PCA Plot") {
  pa <- object$plot_args
  pts <- data.frame(x = pa$x, y = pa$y, group = labels(pa$col))
  
  colorset_reorder <- c("darkorange", "dodgerblue3")
  
  # Compute convex hulls for each group
  hulls <- pts %>%
    group_by(group) %>%
    slice(chull(x, y)) %>%
    ungroup()
  
  g <- ggplot(pts, aes(x = x, y = y, color = group)) +
    geom_point() +
    geom_polygon(data = hulls, aes(x = x, y = y, fill = group, group = group), 
                 alpha = 0.25, color = NA) +
    scale_color_manual(values = colorset_reorder) +
    scale_fill_manual(values = colorset_reorder) +
    theme_minimal() +
    labs(x = x_label, y = y_label) +
    ggtitle(plot_title)
  
  print(g)
}



# For CB1 PCA ellipses 
PCA_CB1_ellipse_eco <- make_ggplot_ellipse(PCA_CB1_eco, x_label = "PC 1: 57.39%", y_label = "PC 2: 12.85%", plot_title = "CB1")
PCA_CB1_1_3_ellipse_eco <- make_ggplot_ellipse(PCA_CB1_1_3_eco, x_label = "PC 1: 57.39%", y_label = "PC 3: 6.32%", plot_title = "CB1")

# For CB2 PCA ellipses 
PCA_CB2_ellipse_eco <- make_ggplot_ellipse(PCA_CB2_eco, x_label = "PC 1: 32.8%", y_label = "PC 2: 16.13%", plot_title = "CB2")
PCA_CB2_1_3_ellipse_eco <- make_ggplot_ellipse(PCA_CB2_1_3_eco, x_label = "PC 1: 32.8%", y_label = "PC 3: 14.83%", plot_title = "CB2")

#### PCA PLOTS WHOLE DF, COLORED BY LAKE####
# Define colors
colors_lake <- c("Finger" = "chocolate","South Rolly" = "dodgerblue2","Spirit" = "lightskyblue","Tern"="burlywood","Walby"="goldenrod2","Watson" = "darkorange")

# Function to plot PCA
plot_pca <- function(pca_data, gdf, color_var, color_palette, title_prefix) {
  # Default PCA plot
  plot(pca_data, main = paste("PCA of", title_prefix), 
       col = color_palette[gdf[[color_var]]], pch = 16, cex = 1.5)
  legend("topright", legend = names(color_palette), col = color_palette, 
         pch = 16, title = color_var, cex = 0.8)
  
  # Loop for additional PC combinations
  for (x in 1:3) {
    for (y in (x+1):4) {
      plot(pca_data, main = paste("PCA of", title_prefix), 
           col = color_palette[gdf[[color_var]]], pch = 16, cex = 1.5, 
           axis1 = x, axis2 = y)
      legend("topright", legend = names(color_palette), col = color_palette, 
             pch = 16, title = color_var, cex = 0.8)
    }
  }
}

# For CB1 PCA plots 
PCA_CB1 <- plot(pca_CB1, main = "PCA of CB1", col = colors_lake[gdf_CB1$Lake], pch = 16, cex = 1.5, plot = FALSE)
PCA_CB1_1_3 <- plot(pca_CB1, main = "PCA of CB1", col = colors_lake[gdf_CB1$Lake], pch = 16, cex = 1.5, axis1 = 1, axis2 = 3, plot = FALSE)

# For CB2 PCA plots 
PCA_CB2 <- plot(pca_CB2, main = "PCA of CB2", col = colors_lake[gdf_CB2$Lake], pch = 16, cex = 1.5, plot = FALSE)
PCA_CB2_1_3 <- plot(pca_CB2, main = "PCA of CB2", col = colors_lake[gdf_CB2$Lake], pch = 16, cex = 1.5, axis1 = 1, axis2 = 3, plot = FALSE)

# function for plots with hulls
make_ggplot_ellipse <- function(object, x_label = "PC1", y_label = "PC2", plot_title = "PCA Plot") {
  pa <- object$plot_args
  pts <- data.frame(x = pa$x, y = pa$y, group = labels(pa$col))
  
  colorset_reorder <- c("chocolate","dodgerblue2","lightskyblue","burlywood","goldenrod2", "darkorange")
  
  # Compute convex hulls
  hulls <- pts %>%
    group_by(group) %>%
    slice(chull(x, y)) %>%
    ungroup()
  
  g <- ggplot(pts, aes(x = x, y = y, color = group)) +
    geom_point() +
    geom_polygon(data = hulls, aes(fill = group, group = group), alpha = 0.25, color = NA) +
    scale_color_manual(values = colorset_reorder) +
    scale_fill_manual(values = colorset_reorder) +
    theme_minimal() +
    labs(x = x_label, y = y_label) +
    ggtitle(plot_title)
  
  print(g)
}


# For CB1 PCA ellipses
PCA_CB1_ellipse <- make_ggplot_ellipse(PCA_CB1, x_label = "PC 1: 57.39%", y_label = "PC 2: 12.85%", plot_title = "CB1")
PCA_CB1_1_3_ellipse <- make_ggplot_ellipse(PCA_CB1_1_3, x_label = "PC 1: 57.39%", y_label = "PC 3: 6.32%", plot_title = "CB1")

# For CB2 PCA ellipses
PCA_CB2_ellipse <- make_ggplot_ellipse(PCA_CB2, x_label = "PC 1: 32.8%", y_label = "PC 2: 16.13%", plot_title = "CB2")
PCA_CB2_1_3_ellipse <- make_ggplot_ellipse(PCA_CB2_1_3, x_label = "PC 1: 32.8%", y_label = "PC 3: 14.83%", plot_title = "CB2")


#### MEAN SHAPE MESHES, VECTORS, HEATMAPS####
msh_CB1 <- mshape(gdf_CB1$coords)

#Changed to the comps of relevance
plotRefToTarget(msh_CB1, pca_CB1$shapes$shapes.comp2$max, method = "vector")
plotRefToTarget(msh_CB1, pca_CB1$shapes$shapes.comp2$min, method = "vector")

msh_CB2 <- mshape(gdf_CB2$coords)

plotRefToTarget(msh_CB2, pca_CB2$shapes$shapes.comp1$min, method = "vector")
plotRefToTarget(msh_CB2, pca_CB2$shapes$shapes.comp1$max, method = "vector")

### LINEAR ANALYSIS FOR EXAMPLES ###
size1 <- procD.lm(coords~log(Csize),data=gdf_CB1)
summary(size1)
eco1 <-procD.lm(coords~Ecology,data=gdf_CB1)
summary(eco1)#non significant interaciton term
lakes1 <- procD.lm(coords~Lake,data=gdf_CB1)
summary(lakes1)

sex_1_24 <- procD.lm(coords~Sex,data = gdf_CB1_X24)
summary(sex_1_24)

sex_2_24 <- procD.lm(coords~Sex,data = gdf_CB2_X24)
summary(sex_2_24)

size2 <- procD.lm(coords~log(Csize),data=gdf_CB2)
summary(size2)
eco2 <-procD.lm(coords~Ecology,data=gdf_CB2)
summary(eco2)#non significant interaciton term
lakes2 <- procD.lm(coords~Lake,data=gdf_CB2)
summary(lakes2)


#Correct for residuals: 
CB2_size_resid <- size2$residuals
#Add shapes back in to make it a shape

pca_CB2_allometry_free <- gm.prcomp(CB2_size_resid)


#Correct for residuals: 
CB1_size_resid <- size1$residuals
#Add shapes back in to make it a shape
pca_CB1_allometry_free <- gm.prcomp(CB1_size_resid)

PCA_CB1 <- plot(pca_CB1, main = "PCA of CB1", col = colors_ecology[gdf_CB1$Ecology], pch = 16, cex = 1.5, plot = FALSE)
PCA_CB1_allo <- plot(pca_CB1_allometry_free, main = "PCA of CB1", col = colors_ecology[gdf_CB1$Ecology], pch = 16, cex = 1.5, plot = FALSE)

PCA_CB1_ellipse_eco <- make_ggplot_ellipse(PCA_CB1_eco, x_label = "PC 1: 57.39%", y_label = "PC 2: 12.85%", plot_title = "CB1")
PCA_CB1_allo_eco <- make_ggplot_ellipse(PCA_CB1_allo , x_label = "PC 1: 59.3%", y_label = "PC 2: 12.87%", plot_title = "CB1 less Allometry")


PCA_CB2 <- plot(pca_CB2, main = "PCA of CB2", col = colors_ecology[gdf_CB2$Ecology], pch = 16, cex = 1.5, plot = FALSE)
PCA_CB2_allo <- plot(pca_CB2_allometry_free, main = "PCA of CB2", col = colors_ecology[gdf_CB2$Ecology], pch = 16, cex = 1.5, plot = FALSE)

PCA_CB2_ellipse_eco <- make_ggplot_ellipse(PCA_CB2_eco, x_label = "PC 1: 57.39%", y_label = "PC 2: 12.85%", plot_title = "CB2")
PCA_CB2_allo_eco <- make_ggplot_ellipse(PCA_CB2_allo , x_label = "PC 1: 59.3%", y_label = "PC 2: 12.87%", plot_title = "CB2 less Allometry")

#Some Post-Hoc Tests: 
pair_eco1 <- pairwise(eco1,groups = gdf_CB1$Ecology)
pair_eco2 <- pairwise(eco2,groups = gdf_CB2$Ecology)

pair_lake1 <- pairwise(lakes1,groups = gdf_CB1$Lake)
pair_lake2 <- pairwise(lakes2,groups = gdf_CB2$Lake)

#Can test for variance differences (can skew tests)
summary(pair_eco1, test.type = "var")
summary(pair_eco2, test.type = "var")
summary(pair_lake1, test.type = "var")
summary(pair_lake2, test.type = "var")

Pair_Lake1 <- summary(pair_lake1)
Pair_Lake2 <- summary(pair_lake2)
write.csv2(summary(Pair_Lake1$summary.table), file = "lake_CB1_Pairwise")
write.csv2(summary(Pair_Lake2$summary.table), file = "lake_CB2_Pairwise")
