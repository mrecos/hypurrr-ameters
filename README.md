# Hypurrr-ameter Grid Search with Purrr and Future
## Blog post Rmd, R Scripts, and Executable Rstudio Binder!

### Description
This repo contains the R code, blog post `Rmd` file, knit `html` file, and perhaps most interestingly, a link to launch an Jupyter binder from which you can spin-up an Rstudio session into this repo! From there you can run the code and play with it right in your browser.  This cool feature is brought to you by the stellar folks who made the [rocker/binder](https://github.com/rocker-org/binder) image and those at [https://mybinder.org/](https://mybinder.org/). This is a really new feature, so hiccups are not unlikely.

This post is based on the hyperparameter grid search example, but I am going to use it as a platform to go over some of the cool features of `purrr` that make it possible to put such an analysis in this `tibble` format.  Further, I hope this post gives people some examples that make the idea of `purrr` "click"; I know it took me some time to get there. By no means a primer on `purrr`, the text will hopefully make some connections between the ideas of `list-columns`, `purrr::map()` functions, and `purrr:nest()` to show off what I interpret as the Tidy-Purrr philosophy. The part about using `future` to parallelize this routine is presented towards the end of the post.

### Link to blog post
[Hypurrr-ameter Grid Search with Purrr and Future](https://matthewdharris.com/2017/12/18/hypurrr-ameter-grid-search-with-purrr-and-future/)

### Executable RStudio Binder
[![Binder](https://dl.dropboxusercontent.com/s/aqbfp8dkp0iw4k9/launch_Rstudio.svg?dl=0)](https://mybinder.org/v2/gh/mrecos/hypurrr-ameters/master?filepath=RMD)

Click the button above (into a new tab) to launch this repo into an Rstudio binder in your browser! After clicking the button, wait a moment for the [https://mybinder.org/](https://mybinder.org/) service to build this repo into a new binder. Once built, you will see a screen like that below. First click `New` on the left hand side, then click `Rstudio Session` from the drop-down list. This will open a new cloud based Rstudio session right in your browser. From there, you can click in the `Files` to the `RMD` folder and then click on the `purrr_gridsearch_blog.Rmd` to open the blog post markdown. Also, there is a strealined version of the main code example at `/CODE/purrr_grid_search_plot.R`. Run, edit, modify the code and have fun!


![](binder_instructions_1.jpeg)


