### ------- Load Packages ---------- ###
library("tidyverse")
library("future")
library("randomForest")
library("rsample")
library("viridis")
### ------- Helper Functions for map() ---------- ###
# breaks CV splits into train (analysis) and test (assessmnet) sets
cv_helper <- function(data, params){
  d <- data %>%
    mutate(mtry  = params$mtry,
           ntree = params$ntree,
           train = map(splits, analysis),
           test  = map(splits, assessment)) %>%
    select(-splits)
}
# the main modeling helper. Trains and Tests RF model on each CV fold
rf_helper  <- function(folds){ 
  rf_model <- function(train,mtry,ntree,test){
    xtest  <- dplyr::select(test,-medv)
    ytest  <- test$medv
    m1 <- randomForest(medv ~., data=train,mtry=mtry,ntree=ntree,
                       xtest=xtest,ytest=ytest,keep.forest=TRUE)
  }
  # prediction function can go here and map in below
  m <- folds %>%
    mutate(model = pmap(list(train,mtry,ntree,test),rf_model))
}
# Extracts test set MSE from RF Model and averages MSE from each tree
MSE_helper <- function(model){
  err_helper <- function(rf){
    mse <- mean(rf$test$mse)
  }
  m2 <- model %>%
    mutate(mse = map_dbl(model, err_helper)) %>%
    dplyr::select(mse)
  mean(m2$mse)
}

### ------- Load Data & Set Parameters ---------- ###
data <- MASS::Boston
searches <- 10 # number of random grid searches
max_trees <- 500
cv_folds <- 5

### -------------------- START non parallel version --------------- ###
# Fit and evaluate all grid searches
model_fits <- seq_len(searches) %>%
  tibble(
    id = .,
    ntree = sample(c(1,seq(25,max_trees,25)),length(id),replace = T),
    mtry  = sample(seq(1,ncol(data)-1,1),length(id),replace = T)
  ) %>%
  nest(-id, .key = "params") %>%
  mutate(splits = list(rsample::vfold_cv(data,cv_folds)), # same resamples in each
         folds  = map2(splits, params, cv_helper),
         model  = map(folds, rf_helper),        # <- non-parallel version
         mse    = map_dbl(model, MSE_helper)) 
# reshape for plotting
MSE_plot <- model_fits %>%
  mutate(mtry   = map_dbl(params, "mtry"),
         ntree  = map_dbl(params, "ntree")) %>%
  dplyr::select(mtry, ntree, mse) %>%
  group_by(mtry, ntree) %>%
  summarise(mse = mean(mse))
# plot results
ggplot() +
  geom_point(data = filter(MSE_plot, mse == min(MSE_plot$mse)),
             aes(x=mtry,y=ntree), color = "red", 
             size = 8, shape = 15, alpha = 0.85) +
  geom_point(data = MSE_plot, aes(x=mtry,y=ntree, size = mse, color = mse)) +
  scale_size(range = c(1,10)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n=ncol(data)-1)) +
  scale_color_viridis() +
  labs(title = "Random Grid Search of RandomForest Hyperparameters",
       subtitle = paste0("Mean MSE from ", cv_folds, "-fold CV over ",
                         searches, " parameter pairs"),
       caption = "(medv ~ ., data = Boston)") +
  theme_bw() +
  theme(
    text = element_text(family = "Iosevka")
  )


### -------------------- START parallel version --------------- ###
future::plan(multisession) # <- setup parallel backend
# Fit and evaluate all grid searches
model_fits <- seq_len(searches) %>%
  tibble(id    = .,
         ntree = sample(c(1,seq(25,max_trees,25)),length(id),replace = T),
         mtry  = sample(seq(1,ncol(data)-1,1),length(id),replace = T)) %>%
  nest(-id, .key = "params") %>%
  mutate(folds  = list(rsample::vfold_cv(data,cv_folds)),
         folds  = map2(folds, params, cv_helper)) %>%
  mutate(model  = map(folds, ~future::future(rf_helper(.x)))) %>%
  mutate(model  = map(model, ~future::value(.x)),
         mse    = map_dbl(model, MSE_helper))
# reshape for plotting
MSE_plot <- model_fits %>%
  mutate(mtry   = map_dbl(params, "mtry"),
         ntree  = map_dbl(params, "ntree")) %>%
  dplyr::select(mtry, ntree, mse) %>%
  group_by(mtry, ntree) %>%
  summarise(mse = mean(mse))
# plot results
ggplot(data = MSE_plot, aes(x=mtry,y=ntree)) +
  geom_point(data = filter(MSE_plot, mse == min(MSE_plot$mse)),
             aes(x=mtry,y=ntree), color = "red", 
             size = 8, shape = 15, alpha = 0.85) +
  geom_point(data = MSE_plot, aes(x=mtry,y=ntree, size = mse, color = mse)) +
  scale_size(range = c(1,10)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n=ncol(data)-1)) +
  scale_color_viridis() +
  labs(title = "Random Grid Search of RandomForest Hyperparameters",
       subtitle = paste0("Mean MSE from ", cv_folds, "-fold CV over ",
                          searches, " parameter pairs"),
       caption = "(medv ~ ., data = Boston)") +
  theme_bw() +
  theme(
    text = element_text(family = "Iosevka")
  )
### -------------------- END parallel version --------------- ###

# write.csv(MSE_plot)

## working bootstrap version
rf_helper <- function(data, params){ # <- for bootsrap resamples only
  d <- rsample::analysis(data$splits[[1]])
  mtry  <- params$mtry
  ntree <- params$ntree
  m1 <- randomForest(Species ~ ., data = d, mtry = mtry, ntree = ntree)
}
rf_pred <- function(data, model){
  d <- rsample::assessment(data$splits[[1]])
  pred <- predict(model, newdata = d)
}
model_fits_bootstrap <- seq(1:10) %>%
  tibble(
    id = .,
    ntree = sample(seq(1,500,25),length(id),replace = T),
    mtry  = sample(seq(1,4,1),length(id),replace = T)
  ) %>%
  nest(-id, .key = "params") %>%
  mutate(data   = list(rsample::bootstraps(iris,1)), # same resamples in each
         model  = map2(data, params, rf_helper),
         pred   = map2(data, model , rf_pred)) 



